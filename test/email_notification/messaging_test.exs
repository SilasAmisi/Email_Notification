defmodule EmailNotification.MessagingTest do
  use EmailNotification.DataCase

  alias EmailNotification.Messaging

  describe "contacts" do
    alias EmailNotification.Messaging.Contact

    import EmailNotification.MessagingFixtures

    @invalid_attrs %{}

    test "list_contacts/0 returns all contacts" do
      contact = contact_fixture()
      assert Messaging.list_contacts() == [contact]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Messaging.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      valid_attrs = %{}

      assert {:ok, %Contact{} = contact} = Messaging.create_contact(valid_attrs)
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_contact(@invalid_attrs)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()
      update_attrs = %{}

      assert {:ok, %Contact{} = contact} = Messaging.update_contact(contact, update_attrs)
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_contact(contact, @invalid_attrs)
      assert contact == Messaging.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Messaging.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Messaging.change_contact(contact)
    end
  end

  describe "groups" do
    alias EmailNotification.Messaging.Group

    import EmailNotification.MessagingFixtures

    @invalid_attrs %{}

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Messaging.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Messaging.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      valid_attrs = %{}

      assert {:ok, %Group{} = group} = Messaging.create_group(valid_attrs)
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      update_attrs = %{}

      assert {:ok, %Group{} = group} = Messaging.update_group(group, update_attrs)
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_group(group, @invalid_attrs)
      assert group == Messaging.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Messaging.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Messaging.change_group(group)
    end
  end

  describe "group_contacts" do
    alias EmailNotification.Messaging.GroupContact

    import EmailNotification.MessagingFixtures

    @invalid_attrs %{}

    test "list_group_contacts/0 returns all group_contacts" do
      group_contact = group_contact_fixture()
      assert Messaging.list_group_contacts() == [group_contact]
    end

    test "get_group_contact!/1 returns the group_contact with given id" do
      group_contact = group_contact_fixture()
      assert Messaging.get_group_contact!(group_contact.id) == group_contact
    end

    test "create_group_contact/1 with valid data creates a group_contact" do
      valid_attrs = %{}

      assert {:ok, %GroupContact{} = group_contact} = Messaging.create_group_contact(valid_attrs)
    end

    test "create_group_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_group_contact(@invalid_attrs)
    end

    test "update_group_contact/2 with valid data updates the group_contact" do
      group_contact = group_contact_fixture()
      update_attrs = %{}

      assert {:ok, %GroupContact{} = group_contact} = Messaging.update_group_contact(group_contact, update_attrs)
    end

    test "update_group_contact/2 with invalid data returns error changeset" do
      group_contact = group_contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_group_contact(group_contact, @invalid_attrs)
      assert group_contact == Messaging.get_group_contact!(group_contact.id)
    end

    test "delete_group_contact/1 deletes the group_contact" do
      group_contact = group_contact_fixture()
      assert {:ok, %GroupContact{}} = Messaging.delete_group_contact(group_contact)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_group_contact!(group_contact.id) end
    end

    test "change_group_contact/1 returns a group_contact changeset" do
      group_contact = group_contact_fixture()
      assert %Ecto.Changeset{} = Messaging.change_group_contact(group_contact)
    end
  end

  describe "emails" do
    alias EmailNotification.Messaging.Email

    import EmailNotification.MessagingFixtures

    @invalid_attrs %{}

    test "list_emails/0 returns all emails" do
      email = email_fixture()
      assert Messaging.list_emails() == [email]
    end

    test "get_email!/1 returns the email with given id" do
      email = email_fixture()
      assert Messaging.get_email!(email.id) == email
    end

    test "create_email/1 with valid data creates a email" do
      valid_attrs = %{}

      assert {:ok, %Email{} = email} = Messaging.create_email(valid_attrs)
    end

    test "create_email/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_email(@invalid_attrs)
    end

    test "update_email/2 with valid data updates the email" do
      email = email_fixture()
      update_attrs = %{}

      assert {:ok, %Email{} = email} = Messaging.update_email(email, update_attrs)
    end

    test "update_email/2 with invalid data returns error changeset" do
      email = email_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_email(email, @invalid_attrs)
      assert email == Messaging.get_email!(email.id)
    end

    test "delete_email/1 deletes the email" do
      email = email_fixture()
      assert {:ok, %Email{}} = Messaging.delete_email(email)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_email!(email.id) end
    end

    test "change_email/1 returns a email changeset" do
      email = email_fixture()
      assert %Ecto.Changeset{} = Messaging.change_email(email)
    end
  end
end
