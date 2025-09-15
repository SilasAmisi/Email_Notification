defmodule EmailNotificationWeb.EmailController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Messaging
  alias EmailNotification.Messaging.Email
  alias EmailNotificationWeb.EmailJSON

  action_fallback EmailNotificationWeb.FallbackController

  # GET /api/emails
  def index(conn, _params) do
    emails = Messaging.list_emails()
    render(conn, EmailJSON, "index.json", emails: emails)
  end

  # GET /api/emails/:id
  def show(conn, %{"id" => id}) do
    email = Messaging.get_email!(id)
    render(conn, EmailJSON, "show.json", email: email)
  end

  # POST /api/emails
  def create(conn, %{"email" => email_params}) do
    with {:ok, %Email{} = email} <- Messaging.create_email(email_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/emails/#{email.id}")
      |> render(EmailJSON, "show.json", email: email)
    end
  end

  # PUT /api/emails/:id
  def update(conn, %{"id" => id, "email" => email_params}) do
    email = Messaging.get_email!(id)

    with {:ok, %Email{} = email} <- Messaging.update_email(email, email_params) do
      render(conn, EmailJSON, "show.json", email: email)
    end
  end

  # DELETE /api/emails/:id
  def delete(conn, %{"id" => id}) do
    email = Messaging.get_email!(id)

    with {:ok, %Email{}} <- Messaging.delete_email(email) do
      send_resp(conn, :no_content, "")
    end
  end
end
