defmodule EmailNotification.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email_address, :string
    field :msisdn, :string
    field :role, :string
    field :plan, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email_address, :msisdn, :role, :plan])
    |> validate_required([:first_name, :last_name, :email_address, :msisdn])
    |> validate_format(:email_address, ~r/@/)
    |> unique_constraint(:email_address)
  end
end
