defmodule EmailNotificationWeb.ContactController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Messaging
  alias EmailNotification.Messaging.Contact
  alias EmailNotificationWeb.ContactJSON

  action_fallback EmailNotificationWeb.FallbackController

  def index(conn, _params) do
    contacts = Messaging.list_contacts()
    render(conn, ContactJSON, "index.json", contacts: contacts)
  end

  def show(conn, %{"id" => id}) do
    contact = Messaging.get_contact!(id)
    render(conn, ContactJSON, "show.json", contact: contact)
  end

  def create(conn, %{"contact" => contact_params}) do
    with {:ok, %Contact{} = contact} <- Messaging.create_contact(contact_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/contacts/#{contact.id}")
      |> render(ContactJSON, "show.json", contact: contact)
    end
  end

  def update(conn, %{"id" => id, "contact" => contact_params}) do
    contact = Messaging.get_contact!(id)

    with {:ok, %Contact{} = contact} <- Messaging.update_contact(contact, contact_params) do
      render(conn, ContactJSON, "show.json", contact: contact)
    end
  end

  def delete(conn, %{"id" => id}) do
    contact = Messaging.get_contact!(id)

    with {:ok, %Contact{}} <- Messaging.delete_contact(contact) do
      send_resp(conn, :no_content, "")
    end
  end
end
