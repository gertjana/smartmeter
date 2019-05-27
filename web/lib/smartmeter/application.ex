defmodule Smartmeter.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(SmartmeterWeb.Endpoint, []),
      Supervisor.child_spec({ConCache, [name: :cache, ttl_check_interval: false]}, id: :cc1),
      Supervisor.child_spec({ConCache, [name: :info,  ttl_check_interval: false]}, id: :cc2),
      worker(Smartmeter.Serial, [Smartmeter.Serial]),
      Smartmeter.InfluxConnection
    ]

    opts = [strategy: :one_for_one, name: Smartmeter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SmartmeterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
