defmodule EmailNotificationWeb.PageController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Accounts
  alias EmailNotification.Messaging

  def home(conn, _params) do
    render(conn, "home.html",
      users: Accounts.list_users(),
      contacts: Messaging.list_contacts(),
      groups: Messaging.list_groups(),
      emails: Messaging.list_emails()
    )
  end
end
