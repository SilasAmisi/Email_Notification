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

    {users, contacts, groups, emails} =
      case current_user do
        %User{role: "superuser"} ->
          {Accounts.list_users(), Messaging.list_contacts(), Messaging.list_groups(), Messaging.list_emails()}

        %User{role: "admin"} ->
          {Accounts.list_users(), Messaging.list_contacts(), Messaging.list_groups(), Messaging.list_emails()}

        %User{id: id} ->
          {
            [], # frontend users don’t see all users
            Messaging.list_contacts() |> Enum.filter(&(&1.user_id == id)),
            [], # frontend users don’t see all groups
            Messaging.list_emails() |> Enum.filter(&(&1.user_id == id))
          }

        _ ->
          {[], [], [], []}
      end

    if Mix.env() == :dev do
      IO.inspect(current_user, label: "💡 Logged-in user")
      IO.inspect(current_user && current_user.role, label: "💡 Logged-in user role")
    end

    render(conn, "home.html",
      users: users,
      contacts: contacts,
      groups: groups,
      emails: emails,
      current_user: current_user
    )
  end
end
