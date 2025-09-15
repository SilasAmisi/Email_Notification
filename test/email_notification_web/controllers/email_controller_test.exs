defmodule EmailNotificationWeb.EmailControllerTest do
  use EmailNotificationWeb.ConnCase

  import EmailNotification.MessagingFixtures
  alias EmailNotification.Messaging.Email

  @create_attrs %{
    status: "some status",
    body: "some body",
    subject: "some subject"
  }
  @update_attrs %{
    status: "some updated status",
    body: "some updated body",
    subject: "some updated subject"
  }
  @invalid_attrs %{status: nil, body: nil, subject: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all emails", %{conn: conn} do
      conn = get(conn, ~p"/api/emails")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create email" do
    test "renders email when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/emails", email: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/emails/#{id}")

      assert %{
               "id" => ^id,
               "body" => "some body",
               "status" => "some status",
               "subject" => "some subject"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/emails", email: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update email" do
    setup [:create_email]

    test "renders email when data is valid", %{conn: conn, email: %Email{id: id} = email} do
      conn = put(conn, ~p"/api/emails/#{email}", email: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/emails/#{id}")

      assert %{
               "id" => ^id,
               "body" => "some updated body",
               "status" => "some updated status",
               "subject" => "some updated subject"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, email: email} do
      conn = put(conn, ~p"/api/emails/#{email}", email: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete email" do
    setup [:create_email]

    test "deletes chosen email", %{conn: conn, email: email} do
      conn = delete(conn, ~p"/api/emails/#{email}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/emails/#{email}")
      end
    end
  end

  defp create_email(_) do
    email = email_fixture()

    %{email: email}
  end
end
