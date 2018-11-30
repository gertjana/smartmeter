defmodule Smartmeter.InfluxConnection do
  use Instream.Connection, otp_app: :smartmeter

  def save_measurement(measurement) do
  	measurement |> Smartmeter.InfluxConnection.write("smartmeter_measurements")
  end
end