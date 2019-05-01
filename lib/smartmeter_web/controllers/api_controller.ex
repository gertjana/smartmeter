defmodule SmartmeterWeb.ApiController do
  use SmartmeterWeb, :controller
  import Logger

  def status(conn, _params) do
    consumed_power = ConCache.get(:my_cache, :active_power_consume_all)
    produced_power = ConCache.get(:my_cache, :active_power_produce_all)
    current_tariff = ConCache.get(:my_cache, :active_tariff)

    conn 
    |> render(SmartmeterWeb.StatusView, "status.json", status: %{consumed_power: consumed_power, current_tariff: current_tariff}) 
  end
end