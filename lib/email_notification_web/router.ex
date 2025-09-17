defmodule EmailNotificationWeb.Router do
  use EmailNotificationWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EmailNotificationWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # -------------------------------
  # Single-page MVP routes (Browser HTML)
  # -------------------------------
  scope "/", EmailNotificationWeb do
    pipe_through :browser

    # Dashboard
    get "/", PageController, :home

    # Auth (forms-based)
    post "/users/register", UserController, :register
    post "/users/login", UserController, :login
    get  "/users/logout", UserController, :logout

    # User management (role-based)
    post "/users/delete", UserController, :delete
    post "/users/admin", UserController, :update_admin
    post "/users/upgrade", UserController, :upgrade
    post "/users/superuser", UserController, :update_superuser   # ✅ uses role == "superuser"

    # Contacts
    resources "/contacts", ContactController, only: [:create]

    # Emails
    resources "/emails", EmailController, only: [:create]
    post "/emails/group", EmailController, :send_group
    post "/emails/retry", EmailController, :retry_failed_browser
    post "/emails/:id/delete", EmailController, :delete_browser   # ✅ browser delete route

    # Groups
    resources "/groups", GroupController, only: [:create]

    # Group-Contacts
    resources "/group_contacts", GroupContactController, only: [:create]
  end

  # -------------------------------
  # API routes (JSON only)
  # -------------------------------
  scope "/api", EmailNotificationWeb do
    pipe_through :api

    # Auth (stateless API, no CSRF)
    post "/users/register", UserController, :register
    post "/users/login", UserController, :login
    delete "/users/logout", UserController, :logout

    # Resources
    resources "/users", UserController, except: [:new, :edit]
    resources "/contacts", ContactController, except: [:new, :edit]
    resources "/emails", EmailController, except: [:new, :edit]
    resources "/groups", GroupController, except: [:new, :edit]
    resources "/group_contacts", GroupContactController, except: [:new, :edit]

    # Extra actions
    post "/emails/:id/retry", EmailController, :retry_failed_api
    post "/groups/:id/send_emails", GroupController, :send_emails
    get  "/groups/:id/email_status", GroupController, :email_status
  end

  # -------------------------------
  # Dev-only routes
  # -------------------------------
  if Application.compile_env(:email_notification, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EmailNotificationWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
