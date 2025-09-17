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

      user_id -> Repo.get(User, user_id)
    end
  end

  # Allow only gold admins or superusers
  defp authorize_group_admin!(%User{role: "superuser"}), do: :ok
  defp authorize_group_admin!(%User{role: "admin", plan: "gold"}), do: :ok
  defp authorize_group_admin!(_), do: {:error, :forbidden}

  # Convert changeset errors into a JSON-safe map
  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  # ==================================================
  # CRUD ACTIONS
  # ==================================================

  def index(conn, _params) do
    current = get_current_user(conn)

    groups =
      cond do
        current == nil -> []
        current.role == "superuser" -> Messaging.list_groups()
        current.role == "admin" && current.plan == "gold" -> Messaging.list_groups()
        true -> []
      end

    conn
    |> put_view(GroupJSON)
    |> render("index.json", groups: groups)
  end

  def show(conn, %{"id" => id}) do
    current = get_current_user(conn)
    group = Messaging.get_group!(id)

    if current && (current.role == "superuser" || (current.role == "admin" && current.plan == "gold")) do
      conn
      |> put_view(GroupJSON)
      |> render("show.json", group: group)
    else
      send_resp(conn, :forbidden, "Access denied")
    end
  end

  def create(conn, %{"group" => group_params}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_group_admin!(current),
         # attach current user_id to the group
         {:ok, %Group{} = group} <- Messaging.create_group(Map.put(group_params, "user_id", current.id)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/groups/#{group.id}")
      |> put_view(GroupJSON)
      |> render("show.json", group: group)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})

      _ ->
        send_resp(conn, :forbidden, "Access denied")
    end
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_group_admin!(current),
         group <- Messaging.get_group!(id),
         {:ok, %Group{} = updated_group} <- Messaging.update_group(group, group_params) do
      conn
      |> put_view(GroupJSON)
      |> render("show.json", group: updated_group)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})

      _ ->
        send_resp(conn, :forbidden, "Access denied")
    end
  end

  def delete(conn, %{"id" => id}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_group_admin!(current),
         group <- Messaging.get_group!(id),
         {:ok, _} <- Messaging.delete_group(group) do
      send_resp(conn, :no_content, "")
    else
      _ -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  # ==================================================
  # GROUP EMAILS (SUPERUSERS OR GOLD ADMINS ONLY)
  # ==================================================

  def send_emails(conn, %{"id" => group_id, "subject" => subject, "body" => body}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_group_admin!(current) do
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
         :ok <- authorize_group_admin!(current) do
      stats = Messaging.group_email_status(group_id)

      conn
      |> put_status(:ok)
      |> json(stats)
    else
      _ -> send_resp(conn, :forbidden, "Access denied")
    end
  end
end
