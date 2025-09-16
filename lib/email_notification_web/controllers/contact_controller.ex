defmodule EmailNotificationWeb.ContactController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Messaging
  alias EmailNotification.Accounts.User
  alias EmailNotification.Repo
  alias EmailNotificationWeb.ContactJSON

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

  # ==================================================
  # ACTIONS
  # ==================================================

  # List contacts: admin sees all, normal user sees own
  def index(conn, _params) do
    current = get_current_user(conn)

    contacts =
      cond do
        current == nil -> []
        current.role == "admin" -> Messaging.list_contacts()
        true -> Messaging.list_contacts_for_user(current.id)
      end

    conn
    |> put_view(ContactJSON)
    |> render("index.json", contacts: contacts)
  end

  # Show a single contact (self or admin)
  def show(conn, %{"id" => id}) do
    current = get_current_user(conn)
    contact = Messaging.get_contact!(id)

    cond do
      current && current.role == "admin" -> render_contact(conn, contact)
      current && contact.user_id == current.id -> render_contact(conn, contact)
      true -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  # Create contact (self or admin)
  def create(conn, %{"contact" => contact_params}) do
    current = get_current_user(conn)

    cond do
      current == nil ->
        send_resp(conn, :unauthorized, "Login required")

      current.role != "admin" ->
        contact_params = Map.put(contact_params, "user_id", current.id)
        do_create(conn, contact_params)

      true ->
        do_create(conn, contact_params)
    end
  end

  defp do_create(conn, contact_params) do
    case Messaging.create_contact(contact_params) do
      {:ok, contact} ->
        conn
        |> put_status(:created)
        |> put_view(ContactJSON)
        |> render("show.json", contact: contact)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    end
  end

  # Update contact (self or admin)
  def update(conn, %{"id" => id, "contact" => contact_params}) do
    current = get_current_user(conn)
    contact = Messaging.get_contact!(id)

    cond do
      current && current.role == "admin" -> do_update(conn, contact, contact_params)
      current && contact.user_id == current.id -> do_update(conn, contact, contact_params)
      true -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  defp do_update(conn, contact, contact_params) do
    case Messaging.update_contact(contact, contact_params) do
      {:ok, contact} -> render_contact(conn, contact)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    end
  end

  # Delete contact (self or admin)
  def delete(conn, %{"id" => id}) do
    current = get_current_user(conn)
    contact = Messaging.get_contact!(id)

    cond do
      current && current.role == "admin" -> do_delete(conn, contact)
      current && contact.user_id == current.id -> do_delete(conn, contact)
      true -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  defp do_delete(conn, contact) do
    case Messaging.delete_contact(contact) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "Unable to delete contact"})
    end
  end

  # ==================================================
  # HELPER
  # ==================================================
  defp render_contact(conn, contact) do
    conn
    |> put_view(ContactJSON)
    |> render("show.json", contact: contact)
  end

  defp translate_error({msg, opts}) do
    # basic translation for errors
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
