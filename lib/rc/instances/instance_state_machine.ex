defmodule RC.Instances.InstanceStateMachine do
  alias RC.Instances

  use Machinery,
    states: ["created", "open", "running", "paused", "not_running", "ended", "maintenance"],
    transitions: %{
      "created" => ["open", "maintenance"],
      "open" => ["running", "maintenance"],
      "running" => ["paused", "not_running", "ended", "maintenance"],
      "paused" => ["running", "ended", "maintenance"],
      "not_running" => ["running", "ended", "maintenance"],
      "maintenance" => ["created", "open", "running", "paused", "not_running", "ended"]
    }

  # without account id
  def log_transition(%Instances.Instance{account_id: account_id, id: instance_id} = _instance, next_state) do
    {:ok, %{instance: instance}} =
      Instances.create_instance_state(%{instance_id: instance_id, state: next_state}, account_id)

    instance
  end
end
