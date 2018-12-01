defmodule SmartmeterWeb.PageController do
  use SmartmeterWeb, :controller
  import Logger

  defp assign_from_cache(conn, key, prefix \\"", postfix \\ "") when is_atom(key) do
  	value = case ConCache.get(:my_cache, key) do
      				nil -> Atom.to_string(key)
      				result -> result  
      			end
  	conn |> assign(key, "#{prefix}#{value}#{postfix}")
  end

  def mbus_device_measurements do
    Smartmeter.Information.get_channels() 
    |> Map.keys
    |> Enum.map(fn channel -> {channel, 
                         {ConCache.get(:my_cache, String.to_atom("mbus_device_measurement_#{channel}")),
                          ConCache.get(:my_cache, String.to_atom("mbus_device_measurement_timestamp_#{channel}"))}} end)
    |> Map.new
  end

  def index(conn, _params) do
    information = Smartmeter.Information.get_from_channel(0)
    conn
      |> assign(:information, information)
      |> assign(:mbus_devices, Smartmeter.Information.get_channels) 
      |> assign(:mbus_device_measurements, mbus_device_measurements()) 
      |> assign_from_cache(:total_energy_consume_normal)
      |> assign_from_cache(:total_energy_consume_low)
      |> assign_from_cache(:total_energy_produce_normal)
      |> assign_from_cache(:total_energy_produce_low)
      |> assign_from_cache(:active_power_consume_all)
      |> assign_from_cache(:active_power_consume_l1)
      |> assign_from_cache(:active_power_consume_l2)
      |> assign_from_cache(:active_power_consume_l3)
      |> assign_from_cache(:active_power_produce_all)
      |> assign_from_cache(:active_power_produce_l1)
      |> assign_from_cache(:active_power_produce_l2)
      |> assign_from_cache(:active_power_produce_l3)
      |> assign_from_cache(:active_voltage_l1)
      |> assign_from_cache(:active_voltage_l2)
      |> assign_from_cache(:active_voltage_l3)
      |> assign_from_cache(:active_amperage_l1)
      |> assign_from_cache(:active_amperage_l2)
      |> assign_from_cache(:active_amperage_l3)
      |> render("index.html")
  end
end
