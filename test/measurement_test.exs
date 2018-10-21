defmodule Smartmeter.MeasurementTest do
  use ExUnit.Case
  alias P1.Telegram, as: Telegram
  alias Smartmeter.Series, as: Series
  alias Smartmeter.Measurements, as: Measurements

  test "Convert P1 TotalEnergy to Series" do
    telegram = %Telegram.TotalEnergy{direction: :consume, tariff: :normal, unit: "kWh", value: 122.45}

    assert {:ok, %Series.TotalEnergy{
      fields: %Series.TotalEnergy.Fields{value: 122.45}, 
      tags: %Series.TotalEnergy.Tags{direction: :consume, energy: :total, tariff: :normal}}} == Measurements.to_serie(telegram)
  end

  test "Convert P1 CurrentEnergy to Series" do
    telegram = %Telegram.CurrentEnergy{direction: :consume, unit: "kW", value: 456}
    assert {:ok, %Series.CurrentEnergy{
      fields: %Series.CurrentEnergy.Fields{value: 456}, 
      tags: %Series.CurrentEnergy.Tags{direction: :consume, energy: :current}}} == Measurements.to_serie(telegram)
  end

end