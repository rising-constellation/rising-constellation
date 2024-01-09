# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RC.Repo.insert!(%RC.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

data =
  case Application.get_env(:rc, :environment) do
    :dev ->
      [
        {"admin@abc", "admin", "Admin", :admin, :active},
        {"user1@abc", "user1", "User1", :user, :active},
        {"user2@abc", "user2", "User2", :user, :active},
        {"user3@abc", "user3", "User3", :user, :active},
        {"user4@abc", "user4", "User4", :admin, :active},
        {"user5@abc", "user5", "User5", :user, :active},
        {"user6@abc", "user6", "User6", :user, :active},
        {"user7@abc", "user7", "User7", :user, :active},
        {"user8@abc", "user8", "User registered", :user, :registered},
        {"user9@abc", "user9", "User inactive", :user, :inactive}
      ]

    :prod ->
      [
        # Put initial user here as follow
        {"email@email.com", "password", "Username", :admin, :active}
      ]
  end

Enum.each(data, fn {email, pwd, pseudo, role, status} ->
  {:ok, account} =
    %RC.Accounts.Account{}
    |> RC.Accounts.Account.changeset_password(%{
      email: email,
      password: pwd,
      name: pseudo,
      role: role,
      status: status
    })
    |> RC.Accounts.Account.changeset_is_free(false)
    |> RC.Repo.insert()

  if role == :admin do
    {:ok, _profile} =
      RC.Accounts.create_profile(%{
        name: account.name,
        avatar: "avatarM_001.jpg",
        age: 40,
        description: "",
        full_name: "",
        long_description: "",
        account_id: account.id
      })
  end

  {:ok, _log} =
    RC.Logs.create_log(
      %{action: :create_account},
      account
    )
end)
