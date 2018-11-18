defmodule SmartmeterWeb.PageController do
  use SmartmeterWeb, :controller
  import Logger

  defp a(conn, key, prefix \\"", postfix \\ "") when is_atom(key) do
  	value = case ConCache.get(:my_cache, key) do
      				nil -> Atom.to_string(key)
      				result -> result  
      			end
  	conn |> assign(key, prefix <> value <> postfix)
  end

  def mbus_device_measurements do
    Smartmeter.Information.get_channels() 
    |> Map.keys
    |> Enum.map(fn c -> {c, 
                         {ConCache.get(:my_cache, String.to_atom("mbus_device_measurement_#{c}")),
                          ConCache.get(:my_cache, String.to_atom("mbus_device_measurement_timestamp_#{c}"))}} end)
    |> Map.new
  end

  def index(conn, _params) do
    information = Smartmeter.Information.getAll
    conn
      |> assign(:information, information)
      |> assign(:mbus_devices, Smartmeter.Information.get_channels) 
      |> assign(:mbus_device_measurements, mbus_device_measurements()) 
      |> a(:total_energy_consumed_normal)
      |> a(:total_energy_consumed_low)
      |> a(:total_energy_produced_normal)
      |> a(:total_energy_produced_low)
      |> a(:active_power_consumed_all)
      |> a(:active_power_consumed_l1)
      |> a(:active_power_consumed_l2)
      |> a(:active_power_consumed_l3)
      |> a(:active_power_produced_all)
      |> a(:active_power_produced_l1)
      |> a(:active_power_produced_l2)
      |> a(:active_power_produced_l3)
      |> a(:voltage_l1)
      |> a(:voltage_l2)
      |> a(:voltage_l3)
      |> a(:amperage_l1)
      |> a(:amperage_l2)
      |> a(:amperage_l3)
      |> render("index.html")
  end
end
