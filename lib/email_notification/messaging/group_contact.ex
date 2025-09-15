defmodule EmailNotification.Messaging.GroupContact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_contacts" do
    field :group_id, :id
    field :contact_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group_contact, attrs) do
    group_contact
    |> cast(attrs, [:group_id, :contact_id])
    |> validate_required([:group_id, :contact_id])
  end
end
