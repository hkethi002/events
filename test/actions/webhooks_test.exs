defmodule Actions.WebhooksManagerTest do
  use ExUnit.Case, async: true

  test "stores webhooks by event_type" do
    {:ok, registered_webhooks} = Actions.WebhooksManager.start_link([])
    assert Actions.WebhooksManager.get_webhooks(registered_webhooks, "file_create") == nil

    Actions.WebhooksManager.register_webhook(registered_webhooks, "file_create", %Actions.Webhook{
      filter: "origin=test@user.com",
      url: "https://localhost:8000/api/test",
      method: "GET"
    })

    assert length(Actions.WebhooksManager.get_webhooks(registered_webhooks, "file_create")) == 1

    Actions.WebhooksManager.register_webhook(registered_webhooks, "file_create", %Actions.Webhook{
      filter: "origin=test@user.com",
      url: "https://localhost:8000/api/two",
      method: "GET"
    })

    assert length(Actions.WebhooksManager.get_webhooks(registered_webhooks, "file_create")) == 2
  end
end
