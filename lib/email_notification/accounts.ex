defmodule EmailNotification.Accounts do
  @moduledoc """
  The Accounts context handles users: registration, updates, and authentication.
  """

  import Ecto.Query, warn: false
  alias EmailNotification.Repo
  alias EmailNotification.Accounts.User

  # ==================================================
  # QUERIES
  # ==================================================

  @doc """
  Returns the list of all users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user by ID (raises if not found).
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by ID (nil if not found).
  """
  def get_user(id), do: Repo.get(User, id)

  # ==================================================
  # CREATE / REGISTER
  # ==================================================

  @doc """
  Creates a user (admin or system-level creation).
  Uses the generic `User.changeset/2` which allows
  setting role/plan explicitly.
  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Registers a user via self-service signup.
  Uses `User.registration_changeset/2` which
  only permits safe fields (role/plan fixed).
  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  # ==================================================
  # UPDATE / DELETE
  # ==================================================

  @doc """
  Updates a user with generic changeset.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns a generic changeset for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  # ==================================================
  # AUTHENTICATION
  # ==================================================

  @doc """
  Authenticates a user by email_address and plain text password.
  Returns {:ok, user} or {:error, :invalid_credentials}.
  """
  def authenticate_user(email_address, password) do
    case Repo.get_by(User, email_address: email_address) do
      nil ->
        {:error, :invalid_credentials}

      %User{password: stored_pw} = user ->
        if stored_pw == password do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end
