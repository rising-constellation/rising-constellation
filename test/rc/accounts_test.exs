defmodule RC.AccountsTest do
  use RC.DataCase, async: true

  alias RC.Accounts
  alias RC.Repo

  describe "accounts" do
    alias RC.Accounts.Account

    @valid_attrs %{
      email: "some@email",
      hashed_password: "some hashed_password",
      password: "some password",
      name: "some name",
      lang: "fr",
      settings: %{},
      role: :user,
      status: :active
    }

    @valid_mixed_case_attrs %{
      email: "Foo@foo.com",
      hashed_password: "some hashed_password",
      password: "some password",
      name: "some name",
      lang: "fr",
      settings: %{},
      role: :user,
      status: :active
    }

    @update_attrs %{
      email: "updated@email",
      password: "some updated password",
      name: "some updated name",
      lang: "fr",
      settings: %{},
      role: :user,
      status: :active
    }

    @invalid_attrs %{email: nil, hashed_password: nil, name: nil, role: nil, status: nil}

    @banned_provider %{
      email: "foo@yopmail.com",
      hashed_password: "some hashed_password",
      password: "some password",
      name: "some name",
      lang: "fr",
      settings: %{},
      role: :user,
      status: :active
    }

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_account()

      account
    end

    test "create_accounts/1 with too long name return error" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_account(
                 @valid_attrs
                 |> Map.put(:name, "VLfOpwEvyIm8wO3aAeu3F01z5xopKzxRyS1gbaaYKxQ63CBI0R6")
               )
    end

    test "list_accounts/0 returns all accounts" do
      {:ok, listed_account} = Accounts.list_accounts(%{}, false)

      assert listed_account.total_entries == Repo.aggregate(RC.Accounts.Account, :count, :id)
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()

      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Accounts.create_account(@valid_attrs)
      assert account.email == "some@email"
      assert account.hashed_password != Argon2.hash_pwd_salt("some hashed_password")
      assert account.name == "some name"
      assert account.role == @valid_attrs.role
      assert account.status == @valid_attrs.status
    end

    test "create_account/1 with email with spaces at the end removes the space" do
      assert {:ok, %Account{} = account} =
               @valid_attrs
               |> Map.put(:email, @valid_attrs.email <> "      ")
               |> Accounts.create_account()

      assert account.email == "some@email"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "create_account/1 with banned email provider returns error changeset" do
      assert {:error, %Ecto.Changeset{errors: [error], valid?: false}} = Accounts.create_account(@banned_provider)
      assert {:email, {"provider is banned", []}} = error
    end

    test "create_account/1 with invalid email returns error changeset" do
      error =
        @valid_attrs
        |> Map.put(:email, "foo")
        |> Accounts.create_account()

      assert {:error, %Ecto.Changeset{errors: [error], valid?: false}} = error
      assert {:email, {"has invalid format", [validation: :format]}} = error
    end

    test "create_account/1 with existing email but different case returns error changeset" do
      assert {:ok, %Account{} = account} = Accounts.create_account(@valid_attrs)
      assert account.email == "some@email"

      error =
        @valid_attrs
        |> Map.put(:name, "foo-bar-baz")
        |> Map.put(:email, "Some@email")
        |> Accounts.create_account()

      assert {:error, %Ecto.Changeset{errors: [error], valid?: false}} = error

      assert {:email,
              {"has already been taken", [{:constraint, :unique}, {:constraint_name, "accounts_lower_email_index"}]}} =
               error
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      old_hashed_password = account.hashed_password

      assert {:ok, %Account{} = account} = Accounts.update_account(account, @update_attrs)
      assert account.email == "updated@email"
      assert account.hashed_password != old_hashed_password
      assert account.name == "some updated name"
      assert account.role == @update_attrs.role
      assert account.status == @update_attrs.status
    end

    test "update_account/2 with email with space removes the space" do
      account = account_fixture()

      update_with_space =
        @update_attrs
        |> Map.put(:email, @update_attrs.email <> "     ")

      assert {:ok, %Account{} = account} =
               account
               |> Accounts.update_account(update_with_space)

      assert account.email == "updated@email"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()

      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()

      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "delete_account/1 deletes the account and the token" do
      account = account_fixture()

      {:ok, token} =
        Accounts.create_account_token(%{account_id: account.id, type: :email_verification, value: "test_token"})

      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
      assert Accounts.get_account_token(token.value, token.type) == nil
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()

      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end

    test "get_account_by_email_and_password/2 returns the right account" do
      account = account_fixture()
      {:ok, returned_account} = Accounts.get_account_by_email_and_password(account.email, @valid_attrs.password)
      assert account == returned_account
    end

    test "get_account_by_email_and_password/2 returns the right account with mixed case email" do
      account = account_fixture(@valid_mixed_case_attrs)
      {:ok, returned_account} = Accounts.get_account_by_email_and_password(account.email, @valid_attrs.password)
      assert account == returned_account
    end

    test "get_account_by_email_and_password/2 with wrong password returns unauthorized" do
      account = account_fixture()
      assert {:error, :unauthorized} = Accounts.get_account_by_email_and_password(account.email, "wrong password")
    end
  end

  describe "profiles" do
    alias RC.Accounts.Profile
    alias RC.Accounts.Account

    @valid_attrs %{
      "avatar" => "some avatar",
      "name" => "some name",
      "full_name" => "some full_name",
      "description" => "some description",
      "long_description" => "some long_description",
      "age" => 30
    }
    @update_attrs %{
      "avatar" => "some updated avatar",
      "name" => "some updated name",
      "full_name" => "some updated full_name",
      "description" => "some updated description",
      "long_description" => "some updated long_description",
      "age" => 50
    }

    @invalid_attrs %{
      "avatar" => nil,
      "name" => nil,
      "full_name" => nil,
      "description" => nil,
      "long_description" => nil,
      "age" => nil
    }

    @account_valid_attrs %{
      email: "some@email",
      hashed_password: "some hashed_password",
      password: "some password",
      name: "some name",
      role: :user,
      status: :active
    }

    def profile_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@account_valid_attrs)
        |> Accounts.create_account()

      profile = Map.put(@valid_attrs, "account_id", account.id)
      Accounts.create_profile(profile)
    end

    test "list_profiles/0 returns all profiles" do
      {:ok, _} = profile_fixture()
      {:ok, paged_profile} = Accounts.list_profiles(%{})

      assert paged_profile.total_entries == 1
    end

    test "get_profile!/1 returns the profile with given id" do
      {:ok, profile} = profile_fixture()

      assert Accounts.get_profile!(profile.id) == profile
    end

    test "create_profile/1 with valid data creates a profile" do
      assert {:ok, %Profile{} = profile} = profile_fixture()
      assert profile.avatar == "some avatar"
      assert profile.name == "some name"
      assert profile.full_name == "some full_name"
      assert profile.description == "some description"
      assert profile.long_description == "some long_description"
      assert profile.age == 30
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      {:ok, profile} = profile_fixture()

      assert {:ok, %Profile{} = profile} = Accounts.update_profile(profile, @update_attrs)
      assert profile.avatar == "some updated avatar"
      assert profile.name == "some updated name"
      assert profile.full_name == "some updated full_name"
      assert profile.description == "some updated description"
      assert profile.long_description == "some updated long_description"
      assert profile.age == 50
    end

    test "update_profile/2 with invalid data returns error changeset" do
      {:ok, profile} = profile_fixture()

      assert {:error, %Ecto.Changeset{}} = Accounts.update_profile(profile, @invalid_attrs)
      assert profile == Accounts.get_profile!(profile.id)
    end

    test "delete_profile/1 deletes the profile" do
      {:ok, profile} = profile_fixture()

      assert {:ok, %Profile{}} = Accounts.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_profile!(profile.id) end
    end

    test "change_profile/1 returns a profile changeset" do
      {:ok, profile} = profile_fixture()

      assert %Ecto.Changeset{} = Accounts.change_profile(profile)
    end

    test "search_profiles/2 returns the right profile" do
      {:ok, profile} = profile_fixture()
      profiles = Accounts.search_profiles(%{}, "some name")

      assert profiles.entries == [profile]
    end

    test "search_profiles/2 returns no profile for a given query" do
      {:ok, _profile} = profile_fixture()
      profiles = Accounts.search_profiles(%{}, "not matching")

      assert profiles.entries == []
    end

    test "search_accounts/1 returns the right account" do
      account = account_fixture()
      accounts = Accounts.search_accounts(%{}, "me")

      assert accounts.entries == [account]
    end

    test "search_accounts/1 returns no account for a given query" do
      _account = account_fixture()
      accounts = Accounts.search_accounts(%{}, "not matching")

      assert accounts.entries == []
    end
  end
end
