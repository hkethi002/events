defmodule Events do
  use Application

  @impl true
  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    Events.Supervisor.start_link(name: Events.Supervisor)
  end
end

defmodule Events.Event do
  defstruct event_type: "", timestamp: "", origin: ""
end
