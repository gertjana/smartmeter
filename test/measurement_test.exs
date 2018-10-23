defmodule Smartmeter.MeasurementTest do
  use ExUnit.Case
  alias P1.Telegram, as: Telegram
  alias Smartmeter.Series, as: Series
  alias Smartmeter.Measurements, as: Measurements

  defp assertTelegram(telegram, expected) do
    assert {:ok, expected} = Measurements.to_serie(telegram) 
  end

  test "Convert P1 TotalEnergy to Series" do
    telegram = %Telegram.TotalEnergy{direction: :consume, tariff: :normal, unit: "kWh", value: 122.45}
    expected = %Series.TotalEnergy{fields: %Series.TotalEnergy.Fields{value: 122.45}, 
                tags: %Series.TotalEnergy.Tags{direction: :consume, energy: :total, tariff: :normal}}
    assertTelegram(telegram, expected)    
  end

  test "Convert P1 ActivePower to Series" do
    telegram = %Telegram.ActivePower{direction: :consume, phase: :all, unit: "kW", value: 456}
    expected = %Series.ActivePower{fields: %Series.ActivePower.Fields{value: 456}, 
                tags: %Series.ActivePower.Tags{direction: :consume, phase: :all, power: :current}}
    assertTelegram(telegram, expected)    
  end

  test "Convert P1 ActivePower for a phase to Series" do
    telegram = %Telegram.ActivePower{direction: :consume, phase: :l1, unit: "kW", value: 123}
    expected = %Series.ActivePower{fields: %Series.ActivePower.Fields{value: 123}, 
                tags: %Series.ActivePower.Tags{direction: :consume, phase: :l1, power: :current}}
    assertTelegram(telegram, expected)    
  end

  test "Convert P1 MbusMeasurement to Series" do
    telegram = %Telegram.MbusDeviceMeasurement{channel: 1, timestamp: "2010-12-09T11:25:00+02:00", unit: "m3", value: 12785.123}
    expected = %Series.MbusMeasurement{fields: %Series.MbusMeasurement.Fields{value: 123}, 
                tags: %Series.MbusMeasurement.Tags{channel: 1, volume: :total}}
    assertTelegram(telegram, expected)    
  end

end