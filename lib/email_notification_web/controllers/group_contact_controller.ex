defmodule EmailNotificationWeb.GroupContactController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Messaging
  alias EmailNotification.Messaging.GroupContact
  alias EmailNotification.Accounts.User
  alias EmailNotification.Repo
  alias EmailNotificationWeb.GroupContactJSON

  action_fallback EmailNotificationWeb.FallbackController

  # ==================================================
  # HELPERS
  # ==================================================

  # First check session (browser), then header (API/Postman)
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

  defp authorize_superuser!(%User{role: "admin", plan: "gold"}), do: :ok
  defp authorize_superuser!(_), do: {:error, :forbidden}

  # ==================================================
  # ACTIONS
  # ==================================================

  def index(conn, _params) do
    current = get_current_user(conn)

    group_contacts =
      if current && current.role == "admin" && current.plan == "gold" do
        Messaging.list_group_contacts()
      else
        []
      end

    conn
    |> put_view(GroupContactJSON)
    |> render("index.json", group_contacts: group_contacts)
  end

  def show(conn, %{"id" => id}) do
    current = get_current_user(conn)
    group_contact = Messaging.get_group_contact!(id)

    if current && current.role == "admin" && current.plan == "gold" do
      conn
      |> put_view(GroupContactJSON)
      |> render("show.json", group_contact: group_contact)
    else
      send_resp(conn, :forbidden, "Access denied")
    end
  end

  def create(conn, %{"group_contact" => gc_params}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_superuser!(current),
         {:ok, %GroupContact{} = group_contact} <- Messaging.create_group_contact(gc_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/group_contacts/#{group_contact.id}")
      |> put_view(GroupContactJSON)
      |> render("show.json", group_contact: group_contact)
    else
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset})

      _ ->
        send_resp(conn, :forbidden, "Access denied")
    end
  end

  def update(conn, %{"id" => id, "group_contact" => gc_params}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_superuser!(current),
         group_contact <- Messaging.get_group_contact!(id),
         {:ok, %GroupContact{} = updated_gc} <- Messaging.update_group_contact(group_contact, gc_params) do
      conn
      |> put_view(GroupContactJSON)
      |> render("show.json", group_contact: updated_gc)
    else
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset})

      _ ->
        send_resp(conn, :forbidden, "Access denied")
    end
  end

  def delete(conn, %{"id" => id}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_superuser!(current),
         group_contact <- Messaging.get_group_contact!(id),
         {:ok, _} <- Messaging.delete_group_contact(group_contact) do
      send_resp(conn, :no_content, "")
    else
      _ -> send_resp(conn, :forbidden, "Access denied")
    end
  end
end
