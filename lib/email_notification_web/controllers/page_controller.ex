defmodule EmailNotificationWeb.PageController do
  use EmailNotificationWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
