defmodule Actions.WebhooksManager do
  use Agent

  @doc """
  Starts a new WebhooksManager Agent.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Get a list of webhooks by event_type.
  """
  def get_webhooks(webhooks, event_type) do
    Agent.get(webhooks, &Map.get(&1, event_type))
  end

  @doc """
  Register a webhook on a specific event type.
  """
  def register_webhook(webhooks, event_type, webhook) do
    Agent.update(
      webhooks,
      &Map.put(
        &1,
        event_type,
        Actions.WebhooksManager.default_list(Map.get(&1, event_type), webhook)
      )
    )
  end

  @doc """
  Default list if nil.
  """
  def default_list(list, item) do
    if list == nil do
      [item]
    else
      list ++ [item]
    end
  end
end

defmodule Actions.Webhook do
  defstruct [:filter, :url, :method]
end
