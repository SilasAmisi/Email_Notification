defmodule EmailNotificationWeb.GroupJSON do
  alias EmailNotification.Messaging.Group

  def index(%{groups: groups}) do
    %{data: Enum.map(groups, &group_json/1)}
  end

  def show(%{group: group}) do
    %{data: group_json(group)}
  end

  defp group_json(%Group{
         id: id,
         name: name,
         inserted_at: inserted_at,
         updated_at: updated_at
       }) do
    %{
      id: id,
      name: name,
      inserted_at: inserted_at,
      updated_at: updated_at
    }
  end
end
