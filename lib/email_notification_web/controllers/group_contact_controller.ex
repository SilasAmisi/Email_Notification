defmodule EmailNotificationWeb.GroupContactController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Messaging
  alias EmailNotification.Messaging.GroupContact
  alias EmailNotificationWeb.GroupContactJSON

  action_fallback EmailNotificationWeb.FallbackController

  def index(conn, _params) do
    group_contacts = Messaging.list_group_contacts()
    render(conn, GroupContactJSON, "index.json", group_contacts: group_contacts)
  end

  def show(conn, %{"id" => id}) do
    group_contact = Messaging.get_group_contact!(id)
    render(conn, GroupContactJSON, "show.json", group_contact: group_contact)
  end

  def create(conn, %{"group_contact" => gc_params}) do
    with {:ok, %GroupContact{} = gc} <- Messaging.create_group_contact(gc_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/group_contacts/#{gc.id}")
      |> render(GroupContactJSON, "show.json", group_contact: gc)
    end
  end

  def update(conn, %{"id" => id, "group_contact" => gc_params}) do
    gc = Messaging.get_group_contact!(id)

    with {:ok, %GroupContact{} = gc} <- Messaging.update_group_contact(gc, gc_params) do
      render(conn, GroupContactJSON, "show.json", group_contact: gc)
    end
  end

  def delete(conn, %{"id" => id}) do
    gc = Messaging.get_group_contact!(id)

    with {:ok, %GroupContact{}} <- Messaging.delete_group_contact(gc) do
      send_resp(conn, :no_content, "")
    end
  end
end
