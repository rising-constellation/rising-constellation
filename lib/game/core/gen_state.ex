defmodule Core.GenState do
  use TypedStruct

  typedstruct enforce: true do
    field(:type, atom())
    field(:instance_id, integer())
    field(:speed, atom())
    field(:agent_id, integer())
    field(:data, any())
    field(:channel, String.t(), enforce: false)
    field(:tick, %Core.Tick{})
    field(:kill, boolean())
  end

  def new(type, instance_id, agent_id, state, channel) do
    metadata = Data.Querier.get_metadata(instance_id)
    speed = Data.Querier.one(Data.Game.Speed, instance_id, metadata[:speed])

    %Core.GenState{
      type: type,
      instance_id: instance_id,
      speed: metadata[:speed],
      agent_id: agent_id,
      data: state,
      channel: channel,
      tick: Core.Tick.new(speed.factor),
      kill: false
    }
  end

  def registry_name(state) do
    {state.instance_id, state.type, state.agent_id}
  end
end
