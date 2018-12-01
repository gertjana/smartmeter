defmodule Smartmeter.Measurements do
	import Logger
  alias Smartmeter.InfluxConnection,  as: InfluxConnection
  alias Smartmeter.Series,            as: Series
  alias Smartmeter.Information,       as: Information
  alias P1.Header,                    as: Header
  alias P1.Channel,                   as: Channel
  alias P1.Tags,                      as: Tags

	def persist(line) do
		case P1.parse(line) do
			{:ok, parsed} ->
          debug inspect(parsed)
          case parsed |> to_serie do
            {:ok, serie} -> InfluxConnection.save_measurement(serie)
            {:error, _} -> store(parsed)
          end
      {:error, reason} -> warn reason
 		end
	end

  defp store([%Header{manufacturer: manufacturer, model: model}]) do
    Information.put("manufacturer", manufacturer)
    Information.put("model", model)
  end

  defp store([_, %Tags{tags: [{:general, item}]}, [value]]) do
    Information.put(Atom.to_string(item), value)
  end

  defp store([%Channel{medium: _, channel: channel}, %Tags{tags: [{:mbus, item}]}, [value]]) do
    Information.put(Atom.to_string(item), value, channel)
  end

  defp store([_,  %Tags{tags: [{:power_failures, item}]}, [value]]) do
    Information.put("power_failures_#{Atom.to_string(item)}", value)    
  end

  defp store(unknown) do
    warn "I dont know what you mean with #{inspect(unknown)}"
  end

  defp value(data, value), do: %{data | fields: %{data.fields | value: value}}

  defp timestamp(data, datetime_str) do
    timestamp = datetime_str 
                |> Timex.parse!("{ISO:Extended}")
                |> Timex.to_datetime
                |> DateTime.to_unix(:nanoseconds)
    %{data | timestamp: timestamp}
  end 

  defp tag(data, tag, value), do: %{data | tags: Map.put(data.tags, tag, value)}

  defp tags(serie, tags) do
    tags.tags |> List.foldl(serie, fn ({k,v}, acc) -> acc |> tag(k,v) end)
  end

  def to_serie([_, %Tags{tags: [{:power, :active}, {:phase, phase}, {:direction, direction}]} = tags, [value]]) do
    ConCache.put(:my_cache, "active_power_#{direction}_#{phase}" |> String.to_atom, value.value)
    {:ok, %Series.ActivePower{} |> tags(tags) |> value(value.value)}
  end

  def to_serie([_, %Tags{tags: [{:energy, :total}, {:direction, direction}, {:tariff, tariff}]} = tags, [value]]) do
    ConCache.put(:my_cache, "total_energy_#{direction}_#{tariff}" |> String.to_atom, value.value)
    {:ok, %Series.TotalEnergy{} |> tags(tags) |> value(value.value)}
  end

  def to_serie([_, %Tags{tags: [{:voltage, :active}, {:phase, phase}]} = tags, [value]]) do
    ConCache.put(:my_cache, "active_voltage_#{phase}" |> String.to_atom, value.value)
    {:ok, %Series.Voltage{} |> tags(tags) |> value(value.value)}
  end

  def to_serie([_, %Tags{tags: [{:amperage, :active}, {:phase, phase}]} = tags, [value]]) do
    ConCache.put(:my_cache, "active_amperage_#{phase}" |> String.to_atom, value.value)
    {:ok, %Series.Amperage{} |> tags(tags) |> value(value.value)}
  end

  def to_serie([_, %Tags{tags: [{:general, :tariff_indicator}]}, [value]]) do
    ConCache.put(:my_cache, "active_tariff" |> String.to_atom, value)
    {:ok, %Series.TariffIndicator{} |> value(value)}
  end

  def to_serie([%Channel{channel: channel}, %Tags{tags: [{:mbus, :measurement}]} = tags, [ts, value]]) do
    {:ok, %Series.MbusMeasurement{} 
    |> tags(tags) |> tag(:volume, :total) |> tag(:channel, channel) 
    |> timestamp(ts)
    |> value(value.value)}
  end

  def to_serie(unknown) do
    {:error, "no measurement serie configured for #{inspect(unknown)}"}
  end
end