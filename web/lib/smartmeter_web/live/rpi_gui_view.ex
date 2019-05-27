defmodule SmartmeterWeb.RpiGuiView do
  use Phoenix.LiveView

  @refresh_interval 10_000
  @nr_of_values 20

  def render(assigns) do
    SmartmeterWeb.PageView.render("rpi_gui.html", assigns)
  end

  def mount(_session, socket) do
    Process.send_after(self(), {:update_status, socket}, @refresh_interval)
    {:ok, assign(socket, get_status())}
  end

  def handle_info({:update_status, socket}, _sender) do
    Process.send_after(self(), {:update_status, socket}, @refresh_interval)
    {:noreply, assign(socket, get_status())}
  end

  defp get_status() do
    consumed_power = ConCache.get(:cache, :active_power_consume_all)
    produced_power = ConCache.get(:cache, :active_power_produce_all)

    %{
      consumed: consumed_power,
      produced: produced_power,
      tariff: tariff(ConCache.get(:cache, :active_tariff)),
      voltage_l1: ConCache.get(:cache, :active_voltage_l1),
      voltage_l2: ConCache.get(:cache, :active_voltage_l2),
      voltage_l3: ConCache.get(:cache, :active_voltage_l3),
      amperage_l1: ConCache.get(:cache, :active_amperage_l1),
      amperage_l2: ConCache.get(:cache, :active_amperage_l2),
      amperage_l3: ConCache.get(:cache, :active_amperage_l3),
      data: get_data(consumed_power, produced_power)
    }
  end

  defp get_data(consumed_power, produced_power) do
    produced_data = update_range(:produced_range, produced_power)
    consumed_data = update_range(:consumed_range, consumed_power)
    Poison.encode!([
      get_serie("Produced", produced_data),
      get_serie("Consumed", consumed_data)
    ])
  end

  defp update_range(key, value) do
    case ConCache.get(:cache, key) do
      nil ->
        ConCache.put(:cache, key, [value])
        [value]
      result ->
        new = [value | result] |> Enum.take(@nr_of_values)
        ConCache.put(:cache, key, new)
        new |> Enum.reverse
    end
  end

  defp get_serie(name, list) do
    data = [1..Enum.count(list), list] |> Enum.zip |> Map.new
    %{name: name, data: data}
  end

  defp tariff(tariff) do
    case tariff do
      "0001" -> "Normal"
      "0002" -> "Low"
      _ -> "No Data"
    end
  end
end
