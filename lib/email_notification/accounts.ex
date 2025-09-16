defmodule EmailNotification.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias EmailNotification.Repo
  alias EmailNotification.Accounts.User

  @doc """
  Returns the list of users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user by ID.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Registration changeset for plain text password.
  """
  def registration_changeset(%User{} = user, attrs) do
    user
    |> Ecto.Changeset.cast(attrs, [:email, :password, :role])
    |> Ecto.Changeset.validate_required([:email, :password])
    |> Ecto.Changeset.validate_format(:email, ~r/@/)
    |> Ecto.Changeset.unique_constraint(:email)
  end

  @doc """
  Creates a user (plain text password).
  """
  def create_user(attrs) do
    %User{}
    |> registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user (plain text password).
  """
  def update_user(%User{} = user, attrs) do
    user
    |> registration_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns a changeset for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    registration_changeset(user, attrs)
  end

  @doc """
  Authenticates a user by email and plain text password.
  """
  def authenticate_user(email, password) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :invalid_credentials}
      %User{password: stored_pw} = user ->
        if stored_pw == password do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end
