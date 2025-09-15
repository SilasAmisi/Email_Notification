defmodule EmailNotificationWeb.GroupContactControllerTest do
  use EmailNotificationWeb.ConnCase

  import EmailNotification.MessagingFixtures
  alias EmailNotification.Messaging.GroupContact

  @create_attrs %{
    role: "some role"
  }
  @update_attrs %{
    role: "some updated role"
  }
  @invalid_attrs %{role: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all group_contacts", %{conn: conn} do
      conn = get(conn, ~p"/api/group_contacts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create group_contact" do
    test "renders group_contact when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/group_contacts", group_contact: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/group_contacts/#{id}")

      assert %{
               "id" => ^id,
               "role" => "some role"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/group_contacts", group_contact: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update group_contact" do
    setup [:create_group_contact]

    test "renders group_contact when data is valid", %{conn: conn, group_contact: %GroupContact{id: id} = group_contact} do
      conn = put(conn, ~p"/api/group_contacts/#{group_contact}", group_contact: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/group_contacts/#{id}")

      assert %{
               "id" => ^id,
               "role" => "some updated role"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, group_contact: group_contact} do
      conn = put(conn, ~p"/api/group_contacts/#{group_contact}", group_contact: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete group_contact" do
    setup [:create_group_contact]

    test "deletes chosen group_contact", %{conn: conn, group_contact: group_contact} do
      conn = delete(conn, ~p"/api/group_contacts/#{group_contact}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/group_contacts/#{group_contact}")
      end
    end
  end

  defp create_group_contact(_) do
    group_contact = group_contact_fixture()

    %{group_contact: group_contact}
  end
end
