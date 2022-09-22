# Script for creating puppet accounts. You can run it as:
#
#     mix puppet.setup

data =
  case Application.get_env(:rc, :environment) do
    :dev ->
      1..50
      |> Enum.map(fn n -> {"puppet#{n}@abc", "puppet", "Puppet n#{n}", :user, :active} end)

    _ ->
      []
  end

Enum.each(data, fn {email, pwd, pseudo, role, status} ->
  {:ok, account} =
    RC.Accounts.create_account(%{
      email: email,
      password: pwd,
      name: pseudo,
      role: role,
      status: status
    })

  {:ok, _profile} =
    RC.Accounts.create_profile(%{
      avatar: "todo",
      name: account.name,
      account_id: account.id
    })

  {:ok, _log} =
    RC.Logs.create_log(
      %{action: :create_account},
      account
    )
end)
