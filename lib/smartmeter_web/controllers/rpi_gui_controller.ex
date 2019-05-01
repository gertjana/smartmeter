defmodule SmartmeterWeb.RpiGuiController do
  use SmartmeterWeb, :controller
  alias Phoenix.LiveView

  plug :put_layout, "nonav.html"
  
  def index(conn, _) do
    LiveView.Controller.live_render(conn, SmartmeterWeb.RpiGuiView, session: %{})
  end
end