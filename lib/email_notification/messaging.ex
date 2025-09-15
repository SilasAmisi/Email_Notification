defmodule EmailNotification.Messaging do
  import Ecto.Query, warn: false
  alias EmailNotification.Repo
  alias EmailNotification.Messaging.{Contact, Group, GroupContact, Email}

  # Contacts
  def list_contacts, do: Repo.all(Contact)
  def get_contact!(id), do: Repo.get!(Contact, id)
  def create_contact(attrs), do: %Contact{} |> Contact.changeset(attrs) |> Repo.insert()
  def update_contact(%Contact{} = contact, attrs), do: contact |> Contact.changeset(attrs) |> Repo.update()
  def delete_contact(%Contact{} = contact), do: Repo.delete(contact)
  def change_contact(%Contact{} = contact, attrs \\ %{}), do: Contact.changeset(contact, attrs)

  # Groups
  def list_groups, do: Repo.all(Group)
  def get_group!(id), do: Repo.get!(Group, id)
  def create_group(attrs), do: %Group{} |> Group.changeset(attrs) |> Repo.insert()
  def update_group(%Group{} = group, attrs), do: group |> Group.changeset(attrs) |> Repo.update()
  def delete_group(%Group{} = group), do: Repo.delete(group)
  def change_group(%Group{} = group, attrs \\ %{}), do: Group.changeset(group, attrs)

  # GroupContacts
  def list_group_contacts, do: Repo.all(GroupContact)
  def get_group_contact!(id), do: Repo.get!(GroupContact, id)
  def create_group_contact(attrs), do: %GroupContact{} |> GroupContact.changeset(attrs) |> Repo.insert()
  def update_group_contact(%GroupContact{} = gc, attrs), do: gc |> GroupContact.changeset(attrs) |> Repo.update()
  def delete_group_contact(%GroupContact{} = gc), do: Repo.delete(gc)
  def change_group_contact(%GroupContact{} = gc, attrs \\ %{}), do: GroupContact.changeset(gc, attrs)

  # Emails (if you plan to implement them)
  def list_emails, do: Repo.all(Email)
  def get_email!(id), do: Repo.get!(Email, id)
  def create_email(attrs), do: %Email{} |> Email.changeset(attrs) |> Repo.insert()
  def update_email(%Email{} = email, attrs), do: email |> Email.changeset(attrs) |> Repo.update()
  def delete_email(%Email{} = email), do: Repo.delete(email)
  def change_email(%Email{} = email, attrs \\ %{}), do: Email.changeset(email, attrs)
end
