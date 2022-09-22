if is_nil(System.get_env("SPEEDUP")) do
  ExUnit.start(exclude: [:replays])
else
  ExUnit.start(exclude: [:test], include: [:replays])
end

:ok = Ecto.Adapters.SQL.Sandbox.checkout(RC.Repo)
