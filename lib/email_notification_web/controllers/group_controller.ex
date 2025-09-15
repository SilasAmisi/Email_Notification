defmodule EmailNotificationWeb.GroupController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Messaging
  alias EmailNotification.Messaging.Group
  alias EmailNotificationWeb.GroupJSON

  action_fallback EmailNotificationWeb.FallbackController

  def index(conn, _params) do
    groups = Messaging.list_groups()
    render(conn, GroupJSON, "index.json", groups: groups)
  end

  def show(conn, %{"id" => id}) do
    group = Messaging.get_group!(id)
    render(conn, GroupJSON, "show.json", group: group)
  end

  def create(conn, %{"group" => group_params}) do
    with {:ok, %Group{} = group} <- Messaging.create_group(group_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/groups/#{group.id}")
      |> render(GroupJSON, "show.json", group: group)
    end
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Messaging.get_group!(id)

    with {:ok, %Group{} = group} <- Messaging.update_group(group, group_params) do
      render(conn, GroupJSON, "show.json", group: group)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Messaging.get_group!(id)

    with {:ok, %Group{}} <- Messaging.delete_group(group) do
      send_resp(conn, :no_content, "")
    end
  end
end
