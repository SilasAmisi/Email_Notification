defmodule EmailNotificationWeb.EmailJSON do
  alias EmailNotification.Messaging.Email

  # For rendering a list of emails
  def index_json(%{emails: emails}) do
    %{data: Enum.map(emails, &email_json/1)}
  end

  # For rendering a single email
  def show_json(%{email: email}) do
    %{data: email_json(email)}
  end

  # Helper function to serialize an individual email
  defp email_json(%Email{} = email) do
    %{
      id: email.id,
      subject: email.subject,
      body: email.body,
      status: email.status,
      user_id: email.user_id,
      contact_id: email.contact_id,
      group_id: email.group_id,
      inserted_at: email.inserted_at,
      updated_at: email.updated_at
    }
  end
end
