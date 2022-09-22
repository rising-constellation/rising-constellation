defmodule Portal.InstanceStateView do
  use Portal, :view
  alias Portal.InstanceStateView

  def render("index.json", %{instance_state: instance_states}) do
    render_many(instance_states, InstanceStateView, "instance_state.json")
  end

  def render("show.json", %{instance_state: instance_state}) do
    render_one(instance_state, InstanceStateView, "instance_state.json")
  end

  def render("instance_state.json", %{state: instance_state}) do
    render("instance_state.json", %{instance_state: instance_state})
  end

  def render("instance_state.json", %{instance_state: instance_state}) do
    %{
      id: instance_state.id,
      state: instance_state.state,
      account_id: instance_state.account_id,
      instance_id: instance_state.instance_id
    }
  end
end
