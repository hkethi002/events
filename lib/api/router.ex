defmodule API.Router do
  use Plug.Router

  plug(Plug.Static, at: "/", from: "static")

  plug(:match)
  plug(:dispatch)
  @template_dir "lib/api/templates"

  get "/api/healthz" do
    # "{\"status\": \"healthy\"}")
    send_resp(conn, 200, "{\"status\": \"healthy\"}")
  end

  get "/" do
    render(conn, "index.html")
  end

  get "/webhooks" do
    {:ok, webhooks} = Actions.Registry.lookup(Actions.Registry, :webhooks)
    render(conn, "webhooks.html", webhooks: Actions.WebhooksManager.get_webhooks(webhooks, "file_download"))
  end

  match _ do
    send_resp(conn, 404, "Oh no! What you seek cannot be found.")
  end

  defp render(%{status: status} = conn, template, assigns \\ []) do
    body =
      @template_dir
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.eex")
      |> EEx.eval_file(assigns)

    send_resp(conn, (status || 200), body)
  end
end
