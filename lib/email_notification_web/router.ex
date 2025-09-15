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

  # Single-page MVP routes
  scope "/", EmailNotificationWeb do
    pipe_through :browser

    get "/", PageController, :home
    post "/create_contact", PageController, :create_contact
    post "/create_group", PageController, :create_group
    post "/create_group_contact", PageController, :create_group_contact
    post "/create_email", PageController, :create_email
  end

  # API routes
  scope "/api", EmailNotificationWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
    resources "/contacts", ContactController, except: [:new, :edit]
    resources "/group_contacts", GroupContactController, except: [:new, :edit]
    resources "/groups", GroupController, except: [:new, :edit]
    resources "/emails", EmailController, except: [:new, :edit]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:email_notification, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EmailNotificationWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
