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
    case Smartmeter.Config.get("serial_enable", :boolean) do
      true ->
        device =  Smartmeter.Config.get("serial_device", :string)
        speed = Smartmeter.Config.get("serial_baudrate", :integer)
        {:ok, pid} = Nerves.UART.start_link
        connect(pid, device, speed)
        info "Opened serial connection #{inspect(pid)} #{device} #{speed}"
      false ->
        warn "Serial connection not enabled"
    end
    {:ok, %{}}
  end

  def handle_info({:nerves_uart, _device, message}, state) do
    info message
    Smartmeter.Measurements.persist(message)
    {:noreply, state}
  end

  def handle_call({:list_ports}, _from, state) do
    ports = Nerves.UART.enumerate |> Enum.map(fn {k,_} -> k end)
    {:reply, ports, state}
  end

  def connect(pid, device, rate) do
    Nerves.UART.open(pid, device, speed: rate, framing: {Nerves.UART.Framing.Line, separator: "\r\n"}, active: true)
  end

  def handle_cast({:nerves_uart, _pid, data}, _from, state) do
    info inspect(data)
    {:no_reply, state}
  end
end