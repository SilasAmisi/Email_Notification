defmodule EmailNotificationWeb.ContactJSON do
  alias EmailNotification.Messaging.Contact

  def index(%{contacts: contacts}) do
    %{data: Enum.map(contacts, &contact_json/1)}
  end

  def show(%{contact: contact}) do
    %{data: contact_json(contact)}
  end

  defp contact_json(%Contact{
         id: id,
         name: name,
         email: email,
         user_id: user_id,
         inserted_at: inserted_at,
         updated_at: updated_at
       }) do
    %{
      id: id,
      name: name,
      email: email,
      user_id: user_id,
      inserted_at: inserted_at,
      updated_at: updated_at
    }
  end
end
