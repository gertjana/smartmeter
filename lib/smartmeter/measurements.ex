defmodule Smartmeter.Measurements do
	import Logger
  alias Smartmeter.InfluxConnection, as: InfluxConnection
  alias P1.Telegram, as: Telegram
  alias Smartmeter.Series, as: Series
  alias Smartmeter.Information, as: Information

	def persist(line) do
		case P1.parse(line) do
			{:ok, parsed} ->
          debug inspect(parsed)
          case parsed |> P1.to_struct do
            {:ok, struct} ->
              debug inspect(struct)
              case struct |> to_serie do
                {:ok, serie} -> InfluxConnection.save_measurement(serie)
                {:error, _} -> store(struct)
              end
            {:error, reason} -> warn reason
          end
      {:error, reason} -> warn reason
 		end
	end

  defp value(data, value), do: %{data | fields: %{data.fields | value: value}}

  defp tag(data, tag, value), do: %{data | tags: Map.put(data.tags, tag, value)}

  defp timestamp(data, datetime_str) do
    timestamp = datetime_str 
                |> Timex.parse!("{ISO:Extended}")
                |> Timex.to_datetime
                |> DateTime.to_unix(:nanoseconds)
    %{data | timestamp: timestamp}
  end 

  defp store(struct) do
    case struct do
      %Telegram.Header{manufacturer: manufacturer, model: model} ->
        Information.put("manufacturer", manufacturer)
        Information.put("model", model)
      %Telegram.Version{version: version} ->
        Information.put("version", version)
      %Telegram.EquipmentIdentifier{channel: channel, identifier: identifier} ->
        Information.put("equipment_identifier", "#{channel}:#{identifier}")
      %Telegram.Timestamp{timestamp: timestamp} ->
        Information.put("timestamp", timestamp)
      %Telegram.TariffIndicator{indicator: indicator} ->
        Information.put("active_tariff", indicator)
      %Telegram.PowerFailure{type: :short, count: count} ->
        Information.put("power_failures_short", count)
      %Telegram.PowerFailure{type: :long, count: count} ->
        Information.put("power_failures_long", count)
      %Telegram.TextMessage{text: text} ->
        Information.put("last_text_message", text)
      %Telegram.MessageCode{code: code} ->
        Information.put("last_message_code", code)        
      unknown -> warn "I dont know what you mean with #{inspect(unknown)}"

    end
  end

  def to_serie(%Telegram.TotalEnergy{direction: direction, tariff: tariff, unit: "kWh", value: value}) do
    {:ok, %Series.TotalEnergy{}
      |> value(value)
      |> tag(:direction, direction)
      |> tag(:energy, :total)
      |> tag(:tariff, tariff)
    }
  end

  def to_serie(%Telegram.ActivePower{direction: direction, phase: phase, unit: "kW", value: value}) do
    {:ok, %Series.ActivePower{}
      |> value(value)
      |> tag(:direction, direction)
      |> tag(:phase, phase)
      |> tag(:power, :active)
    }
  end

  def to_serie(%Telegram.Voltage{phase: phase, unit: "V", value: value}) do
    {:ok, %Series.Voltage{}
      |> value(value)
      |> tag(:voltage, :active)
      |> tag(:phase, phase)
    }
  end

  def to_serie(%Telegram.Amperage{phase: phase, unit: "A", value: value}) do
    {:ok, %Series.Amperage{}
      |> value(value)
      |> tag(:amperage, :active)
      |> tag(:phase, phase)
    }
  end


  def to_serie(%Telegram.MbusDeviceMeasurement{channel: channel, timestamp: timestamp, unit: "m3", value: value}) do
    {:ok, %Series.MbusMeasurement{}
      |> value(value)
      |> tag(:channel, channel)
      |> tag(:volume, :total)
      |> timestamp(timestamp)
  }
  end

  def to_serie(unknown) do
    {:error, "no measurement serie configured for #{inspect(unknown)}"}
  end
end