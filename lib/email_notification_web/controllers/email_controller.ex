defmodule EmailNotificationWeb.EmailController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Messaging
  alias EmailNotification.Accounts.User
  alias EmailNotification.Repo
  alias EmailNotificationWeb.EmailJSON

  action_fallback EmailNotificationWeb.FallbackController

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

  # Allow superusers or gold admins
  defp authorize_email_admin!(%User{role: "superuser"}), do: :ok
  defp authorize_email_admin!(%User{role: "admin", plan: "gold"}), do: :ok
  defp authorize_email_admin!(_), do: {:error, :forbidden}

  # ==================================================
  # BROWSER ACTIONS (home.html.heex)
  # ==================================================

  def create(conn, %{"email" => email_params}) do
    current = get_current_user(conn)

    cond do
      current == nil ->
        conn
        |> put_flash(:error, "Login required")
        |> redirect(to: "/")

      true ->
        email_params = Map.put(email_params, "user_id", current.id)

        case Messaging.create_email(email_params) do
          {:ok, _email} ->
            redirect(conn, to: "/")

          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Failed to send email")
            |> redirect(to: "/")
        end
    end
  end

  # Handles form posting { "email" => %{ "group_id" => ... } }
  def send_group(conn, %{"email" => %{"group_id" => group_id} = email_params}) do
    do_send_group(conn, group_id, email_params)
  end

  # Handles form posting { "group_id" => ... }
  def send_group(conn, %{"group_id" => group_id}) do
    do_send_group(conn, group_id, %{})
  end

  defp do_send_group(conn, group_id, email_params) do
    current = get_current_user(conn)

    cond do
      current == nil ->
        conn
        |> put_flash(:error, "Login required")
        |> redirect(to: "/")

      true ->
        attrs =
          email_params
          |> Map.drop(["group_id"])
          |> Map.put("user_id", current.id)

        results = Messaging.send_group_email(group_id, attrs)

        conn
        |> put_flash(:info, "Group email sent to #{length(results)} contacts")
        |> redirect(to: "/")
    end
  end

  def retry_failed_browser(conn, %{"email_id" => id}) do
    current = get_current_user(conn)
    email = Messaging.get_email!(id)

    with :ok <- authorize_email_admin!(current) do
      case Messaging.retry_email(email) do
        {:ok, _email} -> redirect(conn, to: "/")

        {:error, reason} ->
          conn
          |> put_flash(:error, "Unable to retry email: #{reason}")
          |> redirect(to: "/")
      end
    else
      _ ->
        conn
        |> put_flash(:error, "Access denied")
        |> redirect(to: "/")
    end
  end

  # 🚀 Delete email from browser (frontend or admin)
  def delete_browser(conn, %{"id" => id}) do
    current = get_current_user(conn)
    email = Messaging.get_email!(id)

    cond do
      current && current.role == "admin" -> do_delete_browser(conn, email)
      current && email.user_id == current.id -> do_delete_browser(conn, email)
      true ->
        conn
        |> put_flash(:error, "Access denied")
        |> redirect(to: "/")
    end
  end

  defp do_delete_browser(conn, email) do
    case Messaging.delete_email(email) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Email deleted")
        |> redirect(to: "/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Unable to delete email")
        |> redirect(to: "/")
    end
  end

  # ==================================================
  # API ENDPOINTS
  # ==================================================

  def index(conn, _params) do
    current = get_current_user(conn)

    emails =
      cond do
        current && current.role == "admin" ->
          Messaging.list_emails()

        current ->
          Messaging.list_emails()
          |> Enum.filter(&(&1.user_id == current.id))

        true ->
          []
      end

    conn
    |> put_view(EmailJSON)
    |> render("index.json", emails: emails)
  end

  def show(conn, %{"id" => id}) do
    current = get_current_user(conn)
    email = Messaging.get_email!(id)

    cond do
      current && current.role == "admin" -> render_email(conn, email)
      current && email.user_id == current.id -> render_email(conn, email)
      true -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  def update(conn, %{"id" => id, "email" => email_params}) do
    current = get_current_user(conn)
    email = Messaging.get_email!(id)

    cond do
      current && current.role == "admin" -> do_update(conn, email, email_params)
      current && email.user_id == current.id -> do_update(conn, email, email_params)
      true -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  defp do_update(conn, email, email_params) do
    case Messaging.update_email(email, email_params) do
      {:ok, email} -> render_email(conn, email)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        })
    end
  end

  # API delete
  def delete(conn, %{"id" => id}) do
    current = get_current_user(conn)
    email = Messaging.get_email!(id)

    cond do
      current && current.role == "admin" -> do_delete(conn, email)
      current && email.user_id == current.id -> do_delete(conn, email)
      true -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  defp do_delete(conn, email) do
    case Messaging.delete_email(email) do
      {:ok, _} -> send_resp(conn, :no_content, "")

      {:error, _reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Unable to delete email"})
    end
  end

  # ==================================================
  # API SUPERUSER RETRY
  # ==================================================

  def retry_failed_api(conn, %{"id" => id}) do
    current = get_current_user(conn)
    email = Messaging.get_email!(id)

    with :ok <- authorize_email_admin!(current) do
      case Messaging.retry_email(email) do
        {:ok, email} -> render_email(conn, email)

        {:error, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: reason})
      end
    else
      _ -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  # ==================================================
  # HELPERS
  # ==================================================

  defp render_email(conn, email) do
    conn
    |> put_view(EmailJSON)
    |> render("show.json", email: email)
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
