defmodule SmartmeterWeb.Router do
  use SmartmeterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SmartmeterWeb do
    pipe_through :browser # Use the default browser stack

    get  "/",     PageController,   :index
    get  "/conf", ConfigController, :index
    post "/conf", ConfigController, :submit
    get  "rpigui", RpiGuiController, :index
  end

  scope "/api", SmartmeterWeb do
    pipe_through :api

    get  "/status", ApiController, :status
  end
end
