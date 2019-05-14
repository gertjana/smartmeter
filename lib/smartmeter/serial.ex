defmodule Smartmeter.Serial do
	use GenServer
  import Logger
   
  @doc """
  Starts the serial module.
  """
  def start_link(name) do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok, [name: name])
    info "Started #{__MODULE__} #{inspect(pid)}"
    {:ok, pid}
  end

  def list_ports() do
    GenServer.call(Smartmeter.Serial, {:list_ports})
  end

  # Callbacks

  def init(:ok) do
    framing = get_config(:framing)
    device = get_config(:device)
    speed = get_config(:baudrate)
    case get_config(:enable) do
      true ->
        {:ok, pid} = Nerves.UART.start_link
        connect(pid, device, speed, framing)
        info "Opened serial connection #{inspect(pid)} #{device} #{speed}"
      false ->
        warn "Serial connection not enabled"
    end
    {:ok, %{framing: framing}}
  end

  def handle_info({:nerves_uart, _device, message}, state) do
    debug inspect(message)

    if ! String.starts_with?(message, "#") do
      Smartmeter.Measurements.persist(message, state.framing)
    end
    {:noreply, state}
  end

  def handle_call({:list_ports}, _from, state) do
    ports = Nerves.UART.enumerate |> Enum.map(fn {k,_} -> k end)
    {:reply, ports, state}
  end

  def connect(pid, device, rate, framing) do
    case framing do
      :line -> Nerves.UART.open(pid, device, speed: rate, framing: {Nerves.UART.Framing.Line, separator: "\r\n"}, active: true)
      :telegram -> Nerves.UART.open(pid, device, speed: rate, framing: Smartmeter.Framing.P1, active: true)
    end
  end

  def handle_cast({:nerves_uart, _pid, data}, _from, state) do
    info inspect(data)
    {:no_reply, state}
  end

  defp get_config(item) do
    Application.get_env(:smartmeter, Smartmeter.Serial)[item]
  end

end