defmodule EmailNotification.Messaging.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :user_id, :id   # Added user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :user_id])             # include user_id in cast
    |> validate_required([:name, :user_id])      # require user_id
  end
end
