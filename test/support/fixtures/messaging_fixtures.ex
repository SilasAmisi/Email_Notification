defmodule EmailNotification.MessagingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EmailNotification.Messaging` context.
  """

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}) do
    {:ok, contact} =
      attrs
      |> Enum.into(%{

      })
      |> EmailNotification.Messaging.create_contact()

    contact
  end

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{

      })
      |> EmailNotification.Messaging.create_group()

    group
  end

  @doc """
  Generate a group_contact.
  """
  def group_contact_fixture(attrs \\ %{}) do
    {:ok, group_contact} =
      attrs
      |> Enum.into(%{

      })
      |> EmailNotification.Messaging.create_group_contact()

    group_contact
  end

  @doc """
  Generate a email.
  """
  def email_fixture(attrs \\ %{}) do
    {:ok, email} =
      attrs
      |> Enum.into(%{

      })
      |> EmailNotification.Messaging.create_email()

    email
  end
end
