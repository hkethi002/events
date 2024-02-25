defmodule Events.Consumer do
  def wait_for_messages do
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts(" [x] Received #{payload}")
        {:ok, event} = Jason.decode(payload, keys: :atoms!)

        spawn(fn ->
          Events.Consumer.handle_event(%Events.Event{
            event_type: event[:event_type],
            timestamp: event[:timestamp],
            origin: event[:origin]
          })
        end)

        wait_for_messages()
    end
  end

  def handle_event(event) do
    {:ok, webhooks_manager} = Actions.Registry.lookup(Actions.Registry, :webhooks)
    webhooks = Actions.WebhooksManager.get_webhooks(webhooks_manager, event.event_type)

    for webhook <- webhooks do
      Finch.build(webhook.method, webhook.url) |> Finch.request(MyFinch)
    end
  end

  def start_link(opts) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, opts[:queue_name])
    AMQP.Basic.consume(channel, opts[:queue_name], nil, no_ack: true)
    IO.puts(" [*] Waiting for messages. To exit press CTRL+C, CTRL+C")

    Events.Consumer.wait_for_messages()
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
