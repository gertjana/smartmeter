defmodule InfluxInit do
	import Logger

  @spec init(module) :: :ok
  def init(conn) do
    info "Init InfluxConnection"
    Application.put_env(:smartmeter, conn, conn.config())
  end
end