defmodule Smartmeter.Measurements do
	import Logger
  alias Smartmeter.InfluxConnection, as: InfluxConnection

	def persist(line) do
		case P1.parse(line) do
			{:ok, parsed} ->
          case parsed |> P1.to_struct |> to_serie do
            {:ok, serie} -> InfluxConnection.save_measurement(serie)
            {:error, reason} -> warn reason
          end
			{:error, reason} ->
          error reason
		end
	end

  defp value(data, value), do: %{data | fields: %{data.fields | value: value}}

  defp tag(data, tag, value), do: %{data | tags: Map.put(data.tags, tag, value)}

  defp timestamp(data), do: %{data | timestamp: :os.system_time(:nano_seconds)}

  def to_serie(%P1.Telegram.TotalEnergy{direction: direction, tariff: tariff, unit: "kWh", value: value}) do
    {:ok, %Smartmeter.Series.TotalEnergy{}
      |> value(value)
      |> tag(:direction, direction)
      |> tag(:energy, :total)
      |> tag(:tariff, tariff)
      |> timestamp
    }
  end

  def to_serie(%P1.Telegram.CurrentEnergy{direction: direction, unit: "kW", value: value}) do
    {:ok, %Smartmeter.Series.CurrentEnergy{}
      |> value(value)
      |> tag(:direction, direction)
      |> tag(:energy, :current)
      |> timestamp
    }
  end

  def to_serie(unknown) do
    {:error, "no measurement serie configured for #{inspect(unknown)}"}
  end
end