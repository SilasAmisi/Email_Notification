defmodule EmailNotificationWeb.GroupContactJSON do
  alias EmailNotification.Messaging.GroupContact

  def index(%{group_contacts: group_contacts}) do
    %{data: Enum.map(group_contacts, &group_contact_json/1)}
  end

  def show(%{group_contact: group_contact}) do
    %{data: group_contact_json(group_contact)}
  end

  defp group_contact_json(%GroupContact{
         id: id,
         group_id: group_id,
         contact_id: contact_id,
         inserted_at: inserted_at,
         updated_at: updated_at
       }) do
    %{
      id: id,
      group_id: group_id,
      contact_id: contact_id,
      inserted_at: inserted_at,
      updated_at: updated_at
    }
  end
end
