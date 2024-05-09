defmodule Events do
  require Logger
  use Application

  @impl true
  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    
    webserver = {Plug.Cowboy, plug: API.Router, scheme: :http, options: [port: 4000]}
    {:ok, _} = Supervisor.start_link([webserver], strategy: :one_for_one)

    result = Events.Supervisor.start_link(name: Events.Supervisor)
    result
  end
end

defmodule Events.Event do
  defstruct event_type: "", timestamp: "", origin: ""
end
