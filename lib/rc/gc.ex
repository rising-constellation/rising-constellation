defmodule RC.GC do
  use Task

  @run_every 15 * 60 * 1_000

  def start_link(_arg) do
    Task.start_link(&schedule/0)
  end

  def schedule() do
    receive do
    after
      @run_every ->
        gc()
        schedule()
    end
  end

  defp gc() do
    Process.list() |> Enum.each(&:erlang.garbage_collect/1)
  end
end
