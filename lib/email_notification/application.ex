defmodule EmailNotification.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EmailNotificationWeb.Telemetry,
      EmailNotification.Repo,
      {DNSCluster, query: Application.get_env(:email_notification, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: EmailNotification.PubSub},
      # Start Oban for background job processing
      {Oban, Application.fetch_env!(:email_notification, Oban)},
      # Start to serve requests, typically the last entry
      EmailNotificationWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EmailNotification.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EmailNotificationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
