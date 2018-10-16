defmodule SmartmeterWeb.PageController do
  use SmartmeterWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
