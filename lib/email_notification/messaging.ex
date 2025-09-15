defmodule EmailNotification.Messaging do
  @moduledoc """
  The Messaging context.
  """

  import Ecto.Query, warn: false
  alias EmailNotification.Repo

  alias EmailNotification.Messaging.Contact

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts()
      [%Contact{}, ...]

  """
  def list_contacts do
    raise "TODO"
  end

  @doc """
  Gets a single contact.

  Raises if the Contact does not exist.

  ## Examples

      iex> get_contact!(123)
      %Contact{}

  """
  def get_contact!(id), do: raise "TODO"

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value})
      {:error, ...}

  """
  def create_contact(attrs) do
    raise "TODO"
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, ...}

  """
  def update_contact(%Contact{} = contact, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a Contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, ...}

  """
  def delete_contact(%Contact{} = contact) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Todo{...}

  """
  def change_contact(%Contact{} = contact, _attrs \\ %{}) do
    raise "TODO"
  end

  alias EmailNotification.Messaging.Group

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    raise "TODO"
  end

  @doc """
  Gets a single group.

  Raises if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

  """
  def get_group!(id), do: raise "TODO"

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, ...}

  """
  def create_group(attrs) do
    raise "TODO"
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, ...}

  """
  def update_group(%Group{} = group, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a Group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, ...}

  """
  def delete_group(%Group{} = group) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Todo{...}

  """
  def change_group(%Group{} = group, _attrs \\ %{}) do
    raise "TODO"
  end

  alias EmailNotification.Messaging.GroupContact

  @doc """
  Returns the list of group_contacts.

  ## Examples

      iex> list_group_contacts()
      [%GroupContact{}, ...]

  """
  def list_group_contacts do
    raise "TODO"
  end

  @doc """
  Gets a single group_contact.

  Raises if the Group contact does not exist.

  ## Examples

      iex> get_group_contact!(123)
      %GroupContact{}

  """
  def get_group_contact!(id), do: raise "TODO"

  @doc """
  Creates a group_contact.

  ## Examples

      iex> create_group_contact(%{field: value})
      {:ok, %GroupContact{}}

      iex> create_group_contact(%{field: bad_value})
      {:error, ...}

  """
  def create_group_contact(attrs) do
    raise "TODO"
  end

  @doc """
  Updates a group_contact.

  ## Examples

      iex> update_group_contact(group_contact, %{field: new_value})
      {:ok, %GroupContact{}}

      iex> update_group_contact(group_contact, %{field: bad_value})
      {:error, ...}

  """
  def update_group_contact(%GroupContact{} = group_contact, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a GroupContact.

  ## Examples

      iex> delete_group_contact(group_contact)
      {:ok, %GroupContact{}}

      iex> delete_group_contact(group_contact)
      {:error, ...}

  """
  def delete_group_contact(%GroupContact{} = group_contact) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking group_contact changes.

  ## Examples

      iex> change_group_contact(group_contact)
      %Todo{...}

  """
  def change_group_contact(%GroupContact{} = group_contact, _attrs \\ %{}) do
    raise "TODO"
  end

  alias EmailNotification.Messaging.Email

  @doc """
  Returns the list of emails.

  ## Examples

      iex> list_emails()
      [%Email{}, ...]

  """
  def list_emails do
    raise "TODO"
  end

  @doc """
  Gets a single email.

  Raises if the Email does not exist.

  ## Examples

      iex> get_email!(123)
      %Email{}

  """
  def get_email!(id), do: raise "TODO"

  @doc """
  Creates a email.

  ## Examples

      iex> create_email(%{field: value})
      {:ok, %Email{}}

      iex> create_email(%{field: bad_value})
      {:error, ...}

  """
  def create_email(attrs) do
    raise "TODO"
  end

  @doc """
  Updates a email.

  ## Examples

      iex> update_email(email, %{field: new_value})
      {:ok, %Email{}}

      iex> update_email(email, %{field: bad_value})
      {:error, ...}

  """
  def update_email(%Email{} = email, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a Email.

  ## Examples

      iex> delete_email(email)
      {:ok, %Email{}}

      iex> delete_email(email)
      {:error, ...}

  """
  def delete_email(%Email{} = email) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking email changes.

  ## Examples

      iex> change_email(email)
      %Todo{...}

  """
  def change_email(%Email{} = email, _attrs \\ %{}) do
    raise "TODO"
  end
end
