defmodule Actions.Registry do
  use GenServer

  ## Missing Client API - will add this later

  ## Defining GenServer Callbacks

  @impl true
  def init(:ok) do
    {:ok, webhooks} = Actions.WebhooksManager.start_link([])

    Actions.WebhooksManager.register_webhook(webhooks, "file_download", %Actions.Webhook{
      url: "http://localhost:8000/healthz",
      method: :get
    })

    {:ok, %{:webhooks => webhooks}}
  end

  @impl true
  def handle_call({:lookup, action_type}, _from, action_types) do
    if not Map.has_key?(action_types, action_type) do
      {:reply, {:error, "No such action type"}, action_types}
    else
      {:reply, Map.fetch(action_types, action_type), action_types}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @doc """
  Start the Actions Registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the specific action manager for `action type` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, action_type) do
    GenServer.call(server, {:lookup, action_type})
  end
end
