defmodule InfluxInit do
	import Logger

  @spec init(module) :: :ok
  def init(conn) do
    info "Init InfluxConnection"
    config =
      Keyword.merge(
        conn.config(),
        database:  "smartmeter",
        host: "localhost",
        port: 8086
      )

    Application.put_env(:smartmeter, conn, config)
  end
end