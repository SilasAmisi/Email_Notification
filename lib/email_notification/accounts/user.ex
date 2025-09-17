defmodule EmailNotification.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email_address, :string
    field :msisdn, :string
    field :role, :string, default: "frontend"   # frontend | admin | superuser
    field :plan, :string, default: "standard"   # standard | gold
    field :username, :string
    field :password, :string   # ⚠️ stored as plain text (not secure)

    timestamps(type: :utc_datetime)
  end

  @doc """
  Generic changeset (used for updates & admin create).
  Allows setting role/plan explicitly.
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
    |> validate_format(:email_address, ~r/@/)  # ensure valid email
    |> unique_constraint(:email_address)
    |> unique_constraint(:username)
  end

  @doc """
  Registration changeset (used for self-service signup).
  New users always default to role = "frontend" and plan = "standard".
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :last_name,
      :email_address,
      :msisdn,
      :username,
      :password
    ])
    |> validate_required([:first_name, :last_name, :email_address, :username, :password])
    |> validate_length(:password, min: 6)
    |> validate_format(:email_address, ~r/@/)
    |> unique_constraint(:email_address)
    |> unique_constraint(:username)
  end
end
