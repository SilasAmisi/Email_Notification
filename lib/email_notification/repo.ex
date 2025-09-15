defmodule EmailNotification.Repo do
  use Ecto.Repo,
    otp_app: :email_notification,
    adapter: Ecto.Adapters.Postgres
end
