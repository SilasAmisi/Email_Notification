defmodule EmailNotification.Messaging do
  import Ecto.Query, warn: false
  alias EmailNotification.Repo
  alias EmailNotification.Messaging.{Contact, Group, GroupContact, Email}

  # --------------------------------------------------
  # Contacts
  # --------------------------------------------------
  def list_contacts, do: Repo.all(Contact)

  def list_contacts_for_user(user_id) do
    Repo.all(from c in Contact, where: c.user_id == ^user_id)
  end

  def get_contact!(id), do: Repo.get!(Contact, id)
  def create_contact(attrs), do: %Contact{} |> Contact.changeset(attrs) |> Repo.insert()
  def update_contact(%Contact{} = contact, attrs), do: contact |> Contact.changeset(attrs) |> Repo.update()
  def delete_contact(%Contact{} = contact), do: Repo.delete(contact)
  def change_contact(%Contact{} = contact, attrs \\ %{}), do: Contact.changeset(contact, attrs)

  # --------------------------------------------------
  # Groups
  # --------------------------------------------------
  def list_groups, do: Repo.all(Group)
  def get_group!(id), do: Repo.get!(Group, id)
  def create_group(attrs), do: %Group{} |> Group.changeset(attrs) |> Repo.insert()
  def update_group(%Group{} = group, attrs), do: group |> Group.changeset(attrs) |> Repo.update()
  def delete_group(%Group{} = group), do: Repo.delete(group)
  def change_group(%Group{} = group, attrs \\ %{}), do: Group.changeset(group, attrs)

  # --------------------------------------------------
  # GroupContacts
  # --------------------------------------------------
  def list_group_contacts, do: Repo.all(GroupContact)
  def get_group_contact!(id), do: Repo.get!(GroupContact, id)
  def create_group_contact(attrs), do: %GroupContact{} |> GroupContact.changeset(attrs) |> Repo.insert()
  def update_group_contact(%GroupContact{} = gc, attrs), do: gc |> GroupContact.changeset(attrs) |> Repo.update()
  def delete_group_contact(%GroupContact{} = gc), do: Repo.delete(gc)
  def change_group_contact(%GroupContact{} = gc, attrs \\ %{}), do: GroupContact.changeset(gc, attrs)

  # --------------------------------------------------
  # Emails
  # --------------------------------------------------
  def list_emails, do: Repo.all(Email)
  def list_emails_by_user(user_id), do: Repo.all(from e in Email, where: e.user_id == ^user_id)

  def get_email!(id), do: Repo.get!(Email, id)

  def create_email(attrs) do
    # Assign a random status for testing purposes
    status = Enum.random(["pending", "sent", "failed"])

    %Email{}
    |> Email.changeset(Map.put(attrs, "status", status))
    |> Repo.insert()
  end

  def update_email(%Email{} = email, attrs), do: email |> Email.changeset(attrs) |> Repo.update()
  def delete_email(%Email{} = email), do: Repo.delete(email)
  def change_email(%Email{} = email, attrs \\ %{}), do: Email.changeset(email, attrs)

  # --------------------------------------------------
  # Gold / Superuser Features
  # --------------------------------------------------

  def retry_email(%Email{status: "failed"} = email) do
    update_email(email, %{status: "pending"})
  end

  def retry_email(_), do: {:error, :not_failed}

  def send_group_email(group_id, attrs) do
    contacts =
      GroupContact
      |> where([gc], gc.group_id == ^group_id)
      |> join(:inner, [gc], c in Contact, on: gc.contact_id == c.id)
      |> select([_gc, c], c)
      |> Repo.all()

    Enum.map(contacts, fn contact ->
      # Assign a random status for each group email
      status = Enum.random(["pending", "sent", "failed"])

      %Email{}
      |> Email.changeset(Map.merge(attrs, %{
        "contact_id" => contact.id,
        "group_id" => group_id,
        "status" => status
      }))
      |> Repo.insert()
    end)
  end

  def group_email_status(group_id) do
    query =
      from e in Email,
        where: e.group_id == ^group_id,
        group_by: e.status,
        select: {e.status, count(e.id)}

    Repo.all(query)
    |> Enum.into(%{})
    |> then(fn stats ->
      %{
        sent: Map.get(stats, "sent", 0),
        pending: Map.get(stats, "pending", 0),
        failed: Map.get(stats, "failed", 0)
      }
    end)
  end
end
