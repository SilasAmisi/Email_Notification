defmodule EmailNotificationWeb.PageController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Accounts
  alias EmailNotification.Accounts.User
  alias EmailNotification.Messaging
  alias EmailNotification.Repo

  # ==================================================
  # HELPERS
  # ==================================================
  defp get_current_user(conn) do
    case get_session(conn, :user_id) do
      nil ->
        case Plug.Conn.get_req_header(conn, "x-user-id") do
          [id] -> Repo.get(User, id)
          _ -> nil
        end

      user_id ->
        Repo.get(User, user_id)
    end
  end

  # ==================================================
  # ACTIONS
  # ==================================================
  def home(conn, _params) do
    current_user = get_current_user(conn)

    IO.inspect(current_user, label: "💡 Logged-in user")
    IO.inspect(current_user && current_user.role, label: "💡 Logged-in user role")

    render(conn, "home.html",
      users: Accounts.list_users(),
      contacts: Messaging.list_contacts(),
      groups: Messaging.list_groups(),
      emails: Messaging.list_emails(),
      current_user: current_user
    )
  end
end
