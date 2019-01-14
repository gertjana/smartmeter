defmodule SmartmeterWeb.StatusView do
  use SmartmeterWeb, :view

  def render("status.json", %{status: status}), do: status
end