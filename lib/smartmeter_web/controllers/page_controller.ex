defmodule SmartmeterWeb.PageController do
  use SmartmeterWeb, :controller
  import Logger

  def index(conn, _params) do
    information = Smartmeter.Information.getAll
    info inspect(information)
    conn
      |> assign(:information, information)
      |> render("index.html")
  end
end
