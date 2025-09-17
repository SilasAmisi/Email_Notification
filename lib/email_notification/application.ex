defmodule EmailNotification.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EmailNotificationWeb.Telemetry,
      EmailNotification.Repo,
      {Phoenix.PubSub, name: EmailNotification.PubSub},
      # Start Oban for background job processing
      {Oban, Application.fetch_env!(:email_notification, Oban)},
      # Start to serve requests, typically the last entry
      EmailNotificationWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: EmailNotification.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    EmailNotificationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
