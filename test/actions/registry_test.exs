defmodule Actions.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(Actions.Registry)
    %{registry: registry}
  end

  test "spawns webhooks", %{registry: registry} do
    {:error, _details} = Actions.Registry.lookup(registry, :unknown)

    {:ok, webhooks} = Actions.Registry.lookup(registry, :webhooks)

    Actions.WebhooksManager.register_webhook(webhooks, "files_create", %Actions.Webhook{})
    assert Actions.WebhooksManager.get_webhooks(webhooks, "files_create") == [%Actions.Webhook{}]
  end

  # test "removes buckets on exit", %{registry: registry} do
  #   {:ok, webhooks} = Actions.Registry.lookup(registry, :webhooks)
  #   Actions.WebhooksManager.register_webhook(webhooks, "files_create", %Actions.Webhook{})
  #   assert Actions.WebhooksManager.get_webhooks(webhooks, "files_create") == [%Actions.Webhook{}]
  #   Agent.stop(webhooks)

  #   {:ok, webhooks} = Actions.Registry.lookup(registry, :webhooks)
  #   assert Actions.WebhooksManager.get_webhooks(webhooks, "files_create") == []
  # end
end
