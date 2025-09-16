defmodule EmailNotificationWeb.ContactController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Messaging
  alias EmailNotification.Messaging.Contact
  alias EmailNotificationWeb.ContactJSON

  action_fallback EmailNotificationWeb.FallbackController

  # GET /api/contacts
  def index(conn, _params) do
    contacts = Messaging.list_contacts()
    render(conn, :index, contacts: contacts)
  end

  # GET /api/contacts/:id
  def show(conn, %{"id" => id}) do
    contact = Messaging.get_contact!(id)
    render(conn, :show, contact: contact)
  end

  # POST /api/contacts
  def create(conn, %{"contact" => contact_params}) do
    case Messaging.create_contact(contact_params) do
      {:ok, %Contact{} = contact} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/contacts/#{contact.id}")
        |> render(:show, contact: contact)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  # PUT /api/contacts/:id
  def update(conn, %{"id" => id, "contact" => contact_params}) do
    contact = Messaging.get_contact!(id)

    case Messaging.update_contact(contact, contact_params) do
      {:ok, %Contact{} = contact} ->
        render(conn, :show, contact: contact)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  # DELETE /api/contacts/:id
  def delete(conn, %{"id" => id}) do
    contact = Messaging.get_contact!(id)

    case Messaging.delete_contact(contact) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")

      {:error, _reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Unable to delete contact"})
    end
  end
end
