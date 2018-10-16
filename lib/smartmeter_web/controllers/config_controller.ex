defmodule SmartmeterWeb.ConfigController do
  use SmartmeterWeb, :controller
  import Logger

  def index(conn, _params) do
    saved_serial_device = Smartmeter.Config.get("serial_device", :string)
    has_device = Smartmeter.Serial.list_ports() |> Enum.member?(saved_serial_device)
    serial_device = if has_device, do: Smartmeter.Config.get("serial_device", :string), else: ""
    serial_device_manual = if !has_device, do: Smartmeter.Config.get("serial_device", :string), else: ""
    conn 
      |> assign(:serials, Smartmeter.Serial.list_ports())
      |> assign(:serial_device, serial_device)
      |> assign(:serial_device_manual, serial_device_manual)
      |> assign(:serial_baudrate, Smartmeter.Config.get("serial_baudrate", :integer))
      |> assign(:serial_enable, Smartmeter.Config.get("serial_enable", :boolean))
      |> render("index.html") 	
  end

  def submit(conn, params) do
    case {params["serial_device"], params["serial_device_manual"]} do
      {"", _} -> Smartmeter.Config.put("serial_device", params["serial_device_manual"])
      {_, ""} -> Smartmeter.Config.put("serial_device", params["serial_device"])
      _ -> Smartmeter.Config.put("serial_device", params["serial_device_manual"])
    end
    case params["serial_enable"] do
      nil -> Smartmeter.Config.put("serial_enable", "false")
      _ -> Smartmeter.Config.put("serial_enable", "true")
    end
    Smartmeter.Config.put("serial_baudrate", params["serial_baudrate"])
    index(conn, params)
  end
end