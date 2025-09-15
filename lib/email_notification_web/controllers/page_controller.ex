defmodule EmailNotificationWeb.PageController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Messaging

  def home(conn, _params) do
    render(conn, "home.html",
      contact_changeset: Messaging.change_contact(%Messaging.Contact{}),
      group_changeset: Messaging.change_group(%Messaging.Group{}),
      group_contact_changeset: Messaging.change_group_contact(%Messaging.GroupContact{}),
      email_changeset: Messaging.change_email(%Messaging.Email{})
    )
  end

  def create_contact(conn, %{"contact" => contact_params}) do
    case Messaging.create_contact(contact_params) do
      {:ok, _} -> redirect(conn, to: "/")
      {:error, changeset} -> render(conn, "home.html", contact_changeset: changeset)
    end
  end

  def create_group(conn, %{"group" => group_params}) do
    case Messaging.create_group(group_params) do
      {:ok, _} -> redirect(conn, to: "/")
      {:error, changeset} -> render(conn, "home.html", group_changeset: changeset)
    end
  end

  def create_group_contact(conn, %{"group_contact" => gc_params}) do
    case Messaging.create_group_contact(gc_params) do
      {:ok, _} -> redirect(conn, to: "/")
      {:error, changeset} -> render(conn, "home.html", group_contact_changeset: changeset)
    end
  end

  def create_email(conn, %{"email" => email_params}) do
    case Messaging.create_email(email_params) do
      {:ok, _} -> redirect(conn, to: "/")
      {:error, changeset} -> render(conn, "home.html", email_changeset: changeset)
    end
  end
end
