defmodule EmailNotificationWeb.GroupController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Messaging
  alias EmailNotification.Messaging.Group
  alias EmailNotification.Accounts.User
  alias EmailNotification.Repo
  alias EmailNotificationWeb.GroupJSON

  action_fallback EmailNotificationWeb.FallbackController

  # ==================================================
  # HELPERS
  # ==================================================

  # First check session (browser), then header (API)
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
  # CRUD ACTIONS
  # ==================================================

  def index(conn, _params) do
    current = get_current_user(conn)

    groups =
      cond do
        current == nil -> []
        current.role == "admin" && current.plan == "gold" -> Messaging.list_groups()
        true -> [] # MVP: regular users don’t see groups
      end

    conn
    |> put_view(GroupJSON)
    |> render("index.json", groups: groups)
  end

  def show(conn, %{"id" => id}) do
    current = get_current_user(conn)
    group = Messaging.get_group!(id)

    if current && current.role == "admin" && current.plan == "gold" do
      conn
      |> put_view(GroupJSON)
      |> render("show.json", group: group)
    else
      send_resp(conn, :forbidden, "Access denied")
    end
  end

  def create(conn, %{"group" => group_params}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_superuser!(current),
         {:ok, %Group{} = group} <- Messaging.create_group(group_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/groups/#{group.id}")
      |> put_view(GroupJSON)
      |> render("show.json", group: group)
    else
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset})

      _ ->
        send_resp(conn, :forbidden, "Access denied")
    end
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_superuser!(current),
         group <- Messaging.get_group!(id),
         {:ok, %Group{} = updated_group} <- Messaging.update_group(group, group_params) do
      conn
      |> put_view(GroupJSON)
      |> render("show.json", group: updated_group)
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
         group <- Messaging.get_group!(id),
         {:ok, _} <- Messaging.delete_group(group) do
      send_resp(conn, :no_content, "")
    else
      _ -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  # ==================================================
  # GROUP EMAILS (SUPERUSERS ONLY)
  # ==================================================

  def send_emails(conn, %{"id" => group_id, "subject" => subject, "body" => body}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_superuser!(current) do
      results = Messaging.send_group_email(group_id, %{"subject" => subject, "body" => body})

      conn
      |> put_status(:ok)
      |> json(%{message: "Emails processed", results: results})
    else
      _ -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  def email_status(conn, %{"id" => group_id}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_superuser!(current) do
      stats = Messaging.group_email_status(group_id)

      conn
      |> put_status(:ok)
      |> json(stats)
    else
      _ -> send_resp(conn, :forbidden, "Access denied")
    end
  end
end
