defmodule RC.ClusterSupervisor do
  def child_spec(topologies) do
    %{
      id: __MODULE__,
      start: {Cluster.Supervisor, :start_link, [[topologies, [name: __MODULE__]]]}
    }
  end
end
