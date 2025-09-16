defmodule EmailNotificationWeb.UserController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Accounts
  alias EmailNotification.Accounts.User
  alias EmailNotification.Repo
  alias EmailNotificationWeb.UserJSON

  action_fallback EmailNotificationWeb.FallbackController

  # ====================
  # HELPER: Get logged-in user (stub for now – replace with token/session later)
  # ====================
  defp get_current_user(conn) do
    # For now, assume user_id is passed in headers (e.g., "x-user-id")
    case Plug.Conn.get_req_header(conn, "x-user-id") do
      [id] ->
        Repo.get(User, id)

      _ ->
        nil
    end
  end

  defp authorize_admin!(%User{role: "admin"}), do: :ok
  defp authorize_admin!(_), do: {:error, :forbidden}

  # ====================
  # ACTIONS
  # ====================

  # List all users (admin only)
  def index(conn, _params) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_admin!(current) do
      users = Accounts.list_users()
      conn
      |> put_view(UserJSON)
      |> render("index.json", users: users)
    else
      _ -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  # Show a single user (self or admin)
  def show(conn, %{"id" => id}) do
    current = get_current_user(conn)
    user = Accounts.get_user!(id)

    cond do
      current && current.role == "admin" ->
        render_user(conn, user)

      current && current.id == user.id ->
        render_user(conn, user)

      true ->
        send_resp(conn, :forbidden, "Access denied")
    end
  end

  # Create user (admin only)
  def create(conn, %{"user" => user_params}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_admin!(current),
         {:ok, user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_view(UserJSON)
      |> render("show.json", user: user)
    else
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset})

      _ ->
        send_resp(conn, :forbidden, "Access denied")
    end
  end

  # Update user (self or admin)
  def update(conn, %{"id" => id, "user" => user_params}) do
    current = get_current_user(conn)
    user = Accounts.get_user!(id)

    cond do
      current && current.role == "admin" ->
        do_update(conn, user, user_params)

      current && current.id == user.id ->
        do_update(conn, user, user_params)

      true ->
        send_resp(conn, :forbidden, "Access denied")
    end
  end

  defp do_update(conn, user, user_params) do
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        render_user(conn, user)

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset})
    end
  end

  # Delete user (admin only)
  def delete(conn, %{"id" => id}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_admin!(current),
         user <- Accounts.get_user!(id),
         {:ok, _} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    else
      _ -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  # Registration endpoint (open to anyone)
  def register(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_view(UserJSON)
        |> render("show.json", user: user)

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset})
    end
  end

  # Login endpoint (username or email)
  def login(conn, %{"username" => username, "password" => password}),
    do: do_login(conn, %{username: username, password: password})

  def login(conn, %{"email" => email, "password" => password}),
    do: do_login(conn, %{email: email, password: password})

  def login(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "Missing username/email or password"})

  # Shared login logic
  defp do_login(conn, %{username: username, password: password}) do
    case Repo.get_by(User, username: username) do
      nil -> invalid_credentials(conn)
      user -> check_password(conn, user, password)
    end
  end

  defp do_login(conn, %{email: email, password: password}) do
    case Repo.get_by(User, email_address: email) do
      nil -> invalid_credentials(conn)
      user -> check_password(conn, user, password)
    end
  end

  defp check_password(conn, user, password) do
    if user.password == password do
      conn
      |> json(%{
        message: "Login successful",
        user_id: user.id,
        username: user.username,
        role: user.role
      })
    else
      invalid_credentials(conn)
    end
  end

  defp invalid_credentials(conn),
    do: conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})

  defp render_user(conn, user) do
    conn
    |> put_view(UserJSON)
    |> render("show.json", user: user)
  end
end
