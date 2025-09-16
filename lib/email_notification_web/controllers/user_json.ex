defmodule EmailNotificationWeb.UserJSON do
  alias EmailNotification.Accounts.User

  # For rendering list of users
  def index(%{users: users}) do
    %{data: Enum.map(users, &user_data/1)}
  end

  # For rendering a single user
  def show(%{user: user}) do
    %{data: user_data(user)}
  end

  # Helper to convert a User struct to JSON
  defp user_data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      first_name: user.first_name,
      last_name: user.last_name,
      email_address: user.email_address,
      msisdn: user.msisdn,
      role: user.role,
      plan: user.plan,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
