defmodule EmailNotification.Messaging.Email do
  use Ecto.Schema
  import Ecto.Changeset

  schema "emails" do
    field :subject, :string
    field :body, :string
    field :status, :string
    field :user_id, :id
    field :contact_id, :id
    field :group_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:subject, :body, :status])
    |> validate_required([:subject, :body, :status])
  end
end
