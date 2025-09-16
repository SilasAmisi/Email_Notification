defmodule EmailNotification.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email_address, :string
    field :msisdn, :string
    field :role, :string, default: "frontend"   # frontend, admin, superuser
    field :plan, :string, default: "standard"   # standard, gold
    field :username, :string
    field :password, :string   # plain text storage (⚠️ not secure, but as per your request)

    timestamps(type: :utc_datetime)
  end

  @doc """
  Regular changeset (for updates)
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :last_name,
      :email_address,
      :msisdn,
      :role,
      :plan,
      :username,
      :password
    ])
    |> validate_required([:first_name, :last_name, :email_address, :username, :password])
    |> unique_constraint(:email_address)
    |> unique_constraint(:username)
  end

  @doc """
  Registration changeset
  """
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> validate_length(:password, min: 6)
  end
end
