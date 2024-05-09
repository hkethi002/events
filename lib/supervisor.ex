defmodule Events.Supervisor do
  require Logger
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Finch, name: MyFinch},
      {Actions.Registry, name: Actions.Registry},
      {Events.Consumer, name: Events.Consumer, queue_name: "rtapi_events"}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
