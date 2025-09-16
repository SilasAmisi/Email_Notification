defmodule EmailNotification.Messaging.Email do
  use Ecto.Schema
  import Ecto.Changeset

  schema "emails" do
    field :subject, :string
    field :body, :string
    field :status, :string, default: "pending"

    belongs_to :user, EmailNotification.Accounts.User
    belongs_to :contact, EmailNotification.Messaging.Contact
    belongs_to :group, EmailNotification.Messaging.Group

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:subject, :body, :status, :user_id, :contact_id, :group_id])
    |> validate_required([:subject, :body, :status])
    |> validate_assoc_presence()
  end

  defp validate_assoc_presence(changeset) do
    if get_field(changeset, :user_id) || get_field(changeset, :contact_id) || get_field(changeset, :group_id) do
      changeset
    else
      add_error(changeset, :base, "Email must belong to a user, contact, or group")
    end
  end
end
