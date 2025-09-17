defmodule EmailNotificationWeb.UserController do
  use EmailNotificationWeb, :controller

  alias EmailNotification.Accounts
  alias EmailNotification.Accounts.User
  alias EmailNotification.Repo
  alias EmailNotificationWeb.UserJSON

  action_fallback EmailNotificationWeb.FallbackController

  # ==================================================
  # HELPERS
  # ==================================================

  # Get logged-in user (first check session, then header for API clients)
  defp get_current_user(conn) do
    case get_session(conn, :user_id) do
      nil ->
        case Plug.Conn.get_req_header(conn, "x-user-id") do
          [id] -> Repo.get(User, id)
          _ -> nil
        end

      user_id ->
        Repo.get(User, user_id)
    end
  end

  # Authorization helpers
  defp authorize_admin!(%User{role: "admin"}), do: :ok
  defp authorize_admin!(%User{role: "superuser"}), do: :ok
  defp authorize_admin!(_), do: {:error, :forbidden}

  defp authorize_superuser!(%User{role: "superuser"}), do: :ok
  defp authorize_superuser!(_), do: {:error, :forbidden}

  # ==================================================
  # ACTIONS
  # ==================================================

  # List all users (admin or superuser only)
  def index(conn, _params) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_admin!(current) do
      users = Accounts.list_users()
      conn |> put_view(UserJSON) |> render("index.json", users: users)
    else
      _ -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  # Show a single user (self, admin, or superuser)
  def show(conn, %{"id" => id}) do
    current = get_current_user(conn)
    user = Accounts.get_user!(id)

    cond do
      current && current.role == "superuser" -> render_user(conn, user)
      current && current.role == "admin" -> render_user(conn, user)
      current && current.id == user.id -> render_user(conn, user)
      true -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  # Create user (admin or superuser unless first user)
  def create(conn, %{"user" => user_params}) do
    user_params = normalize_email_params(user_params)

    if Accounts.list_users() == [] do
      case Accounts.create_user(user_params) do
        {:ok, user} ->
          conn
          |> put_status(:created)
          |> put_view(UserJSON)
          |> render("show.json", user: user)

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset})
      end
    else
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
  end

  # Update user (self, admin, or superuser)
  def update(conn, %{"id" => id, "user" => user_params}) do
    current = get_current_user(conn)
    user = Accounts.get_user!(id)

    user_params = normalize_email_params(user_params)

    cond do
      current && current.role == "superuser" -> do_update(conn, user, user_params)
      current && current.role == "admin" -> do_update(conn, user, user_params)
      current && current.id == user.id -> do_update(conn, user, user_params)
      true -> send_resp(conn, :forbidden, "Access denied")
    end
  end

  defp do_update(conn, user, user_params) do
    case Accounts.update_user(user, user_params) do
      {:ok, user} -> render_user(conn, user)
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset})
    end
  end

  # Delete user (admin or superuser only)
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

  # Registration endpoint (open)
  def register(conn, %{"user" => user_params}) do
    user_params = normalize_email_params(user_params)
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> put_status(:created)
        |> put_view(UserJSON)
        |> render("show.json", user: user)

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset})
    end
  end

  # Login (session-based + JSON)
  def login(conn, %{"email_address" => email, "password" => password}) do
    case Repo.get_by(User, email_address: email) do
      nil ->
        invalid_credentials(conn)

      user ->
        if user.password == password do
          conn
          |> put_session(:user_id, user.id)
          |> configure_session(renew: true)
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
  end

  def login(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "Missing email or password"})

  # Logout (clear session)
  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  # Manage admin rights (grant/revoke) – superuser only
  def update_admin(conn, %{"user_id" => user_id, "action" => action}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_superuser!(current),
         user <- Repo.get(User, user_id) do
      new_role =
        case action do
          "grant" -> "admin"
          "revoke" -> "frontend"
          _ -> user.role
        end

      case Accounts.update_user(user, %{"role" => new_role}) do
        {:ok, _updated} ->
          conn
          |> put_flash(:info, "User role updated")
          |> redirect(to: "/")

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Failed to update role")
          |> redirect(to: "/")
      end
    else
      _ ->
        conn
        |> put_flash(:error, "Not authorized")
        |> redirect(to: "/")
    end
  end

  # Manage superuser rights (grant/revoke) – only superuser can do this
  def update_superuser(conn, %{"user_id" => user_id, "action" => action}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_superuser!(current),
         user <- Repo.get(User, user_id) do
      new_role =
        case action do
          "grant" -> "superuser"
          "revoke" -> "frontend"
          _ -> user.role
        end

      case Accounts.update_user(user, %{"role" => new_role}) do
        {:ok, _updated} ->
          conn
          |> put_flash(:info, "Superuser role updated")
          |> redirect(to: "/")

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Failed to update superuser role")
          |> redirect(to: "/")
      end
    else
      _ ->
        conn
        |> put_flash(:error, "Not authorized")
        |> redirect(to: "/")
    end
  end

  # Upgrade/downgrade user plan – superuser only
  def upgrade(conn, %{"user_id" => user_id}) do
    with %User{} = current <- get_current_user(conn),
         :ok <- authorize_superuser!(current),
         %User{} = user <- Repo.get(User, user_id) do
      new_plan =
        case user.plan do
          "gold" -> "standard"
          _ -> "gold"
        end

      case Accounts.update_user(user, %{"plan" => new_plan}) do
        {:ok, _updated} ->
          conn
          |> put_flash(:info, "User plan updated to #{new_plan}")
          |> redirect(to: "/")

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Failed to update user plan")
          |> redirect(to: "/")
      end
    else
      nil ->
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: "/")

      _ ->
        conn
        |> put_flash(:error, "Not authorized")
        |> redirect(to: "/")
    end
  end

  defp invalid_credentials(conn),
    do: conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})

  # ==================================================
  # HELPERS
  # ==================================================

  defp render_user(conn, user) do
    conn
    |> put_view(UserJSON)
    |> render("show.json", user: user)
  end

  defp normalize_email_params(params) do
    params
    |> Map.drop(["email"])
    |> Map.put_new("email_address", params["email"] || params["email_address"])
  end
end
