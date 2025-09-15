defmodule EmailNotificationWeb.UserControllerTest do
  use EmailNotificationWeb.ConnCase

  import EmailNotification.AccountsFixtures
  alias EmailNotification.Accounts.User

  @create_attrs %{
    plan: "some plan",
    role: "some role",
    first_name: "some first_name",
    last_name: "some last_name",
    email_address: "some email_address",
    msisdn: "some msisdn"
  }
  @update_attrs %{
    plan: "some updated plan",
    role: "some updated role",
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    email_address: "some updated email_address",
    msisdn: "some updated msisdn"
  }
  @invalid_attrs %{plan: nil, role: nil, first_name: nil, last_name: nil, email_address: nil, msisdn: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/api/users")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "email_address" => "some email_address",
               "first_name" => "some first_name",
               "last_name" => "some last_name",
               "msisdn" => "some msisdn",
               "plan" => "some plan",
               "role" => "some role"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "email_address" => "some updated email_address",
               "first_name" => "some updated first_name",
               "last_name" => "some updated last_name",
               "msisdn" => "some updated msisdn",
               "plan" => "some updated plan",
               "role" => "some updated role"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/users/#{user}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/users/#{user}")
      end
    end
  end

  defp create_user(_) do
    user = user_fixture()

    %{user: user}
  end
end
