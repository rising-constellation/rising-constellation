defmodule RC.Fixtures do
  alias RC.Accounts
  alias RC.Groups
  alias RC.Groups.Group
  alias RC.Blog

  use Portal, :controller

  def group_valid_attrs do
    %{
      name: "some group"
    }
  end

  #### Account ####

  # Attributes
  def account_valid_user_attrs do
    %{
      email: "user@user",
      hashed_password: "some hashed_password",
      password: "some password",
      name: "some name",
      role: :user,
      status: :registered
    }
  end

  def account2_valid_user_attrs do
    %{
      email: "user2@user2",
      hashed_password: "some hashed_password",
      password: "some password",
      name: "some other name",
      role: :user,
      status: :registered
    }
  end

  def account3_valid_user_attrs do
    %{
      email: "user3@user3",
      hashed_password: "some hashed_password",
      password: "some password",
      name: "some another name",
      role: :user,
      status: :registered
    }
  end

  def account_valid_admin_attrs do
    %{
      email: "admin@admin",
      hashed_password: "some admin hashed_password",
      password: "some admin password",
      name: "some admin name",
      role: :admin,
      status: :registered
    }
  end

  def account_update_attrs do
    %{
      email: "updated@email",
      password: "some updated password",
      name: "some updated name",
      role: :user,
      status: :registered
    }
  end

  def account_invalid_email_attrs do
    %{
      email: "invalid",
      password: "some password",
      name: "some name",
      role: :user,
      status: :active
    }
  end

  def account_invalid_attrs do
    %{email: nil, hashed_password: nil, name: nil, role: nil, status: nil}
  end

  #### Blog ####

  def blog_post_valid_attrs do
    %{
      title: "some title",
      slug: "some slug",
      content_raw: "some content_raw",
      language: "fr",
      picture: "some picture",
      summary_raw: "some summary_raw"
    }
  end

  def blog_post_update_attrs do
    %{
      title: "some updated title",
      slug: "some updated slug",
      content_raw: "some updated content_raw",
      language: "en",
      picture: "some updated picture",
      summary_raw: "some updated summary_raw"
    }
  end

  def blog_category_valid_attrs do
    %{name: "some name", slug: "some slug", language: "fr"}
  end

  def blog_post_invalid_attrs do
    %{title: nil, slug: nil, content_raw: nil, language: nil, picture: nil, summary_raw: nil}
  end

  def create_group(_) do
    {admin, user, user_author} = fixture(:blog_writers_group)
    {:ok, user: user, admin: admin, user_author: user_author}
  end

  def category_fixture() do
    {:ok, category} = Blog.create_category(blog_category_valid_attrs())
    category
  end

  def post_fixture(attrs \\ %{}) do
    {admin, user, user_author} = fixture(:blog_writers_group)

    category = category_fixture()

    {:ok, post} =
      attrs
      |> Enum.into(blog_post_valid_attrs())
      |> Map.put(:account_id, admin.id)
      |> Map.put(:category_id, category.id)
      |> Blog.create_post()

    {post, admin, user, user_author}
  end

  # for setups
  def create_post(_) do
    {post, admin, user, user_author} = post_fixture()
    {:ok, post: post, user: user, admin: admin, user_author: user_author}
  end

  # Setups

  def create_account_admin(_) do
    account = fixture(:admin)
    {:ok, account: account}
  end

  def create_account_user(_) do
    account = fixture(:user)
    {:ok, account: account}
  end

  def create_account_user_registered(_) do
    account = fixture(:user_registered)
    {:ok, account: account}
  end

  #### Profile ####
  # Access
  def profile_valid_attrs do
    %{
      "avatar" => "some avatar",
      "name" => "some name",
      "full_name" => "some full_name",
      "description" => "some description",
      "long_description" => "some long_description",
      "age" => 30
    }
  end

  def profile_update_attrs do
    %{
      "avatar" => "some updated avatar",
      "name" => "some updated name",
      "full_name" => "some updated full_name",
      "description" => "some updated description",
      "long_description" => "some updated long_description",
      "age" => 50
    }
  end

  def profile_invalid_attrs do
    %{
      "avatar" => nil,
      "name" => nil,
      "full_name" => nil,
      "description" => nil,
      "long_description" => nil,
      "age" => nil
    }
  end

  #### Login ####

  def login(conn, account) do
    {:ok, jwt, _full_claims} = RC.Guardian.encode_and_sign(account, %{})

    conn =
      conn
      |> RC.Guardian.Plug.sign_in(account)
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> put_req_header("content-type", "application/json")

    conn
  end

  # Fixtures
  def fixture(:admin), do: create_and_get_account(account_valid_admin_attrs())

  def fixture(:user), do: create_and_get_account(account_valid_user_attrs())

  def fixture(:user2), do: create_and_get_account(account2_valid_user_attrs())

  def fixture(:user3), do: create_and_get_account(account3_valid_user_attrs())

  def fixture(:user_registered) do
    create_and_get_account(account_valid_user_attrs()) |> Map.put(:status, :registered)
  end

  def fixture(:group) do
    {:ok, group} =
      %{}
      |> Enum.into(group_valid_attrs())
      |> Groups.create_group()

    # preloaded fields
    group = Groups.get_group(group.id)

    group
  end

  def fixture(:blog_writers_group) do
    user = fixture(:user)
    user_author = fixture(:user2)
    admin = fixture(:admin)
    blog_group_name = Application.get_env(:rc, RC.Groups) |> Keyword.get(:blog_group_name)

    # no changeset to bypass reserved name constraint
    {:ok, group} = RC.Repo.insert(%Group{name: blog_group_name})
    {:ok, _} = Groups.insert_accounts(group, [user_author.id])

    {admin, user, user_author}
  end

  def create_and_get_account(attrs) do
    {:ok, account} = create_account(attrs)

    account
  end

  def create_account(attrs) do
    case Accounts.create_account(attrs) do
      {:ok, account} ->
        Ecto.Changeset.change(account, money: 1_000_000)
        |> RC.Repo.update()

      err ->
        err
    end
  end
end
