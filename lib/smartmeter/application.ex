defmodule Smartmeter.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Smartmeter.Repo, []),
      supervisor(SmartmeterWeb.Endpoint, []),
      {ConCache, [name: :my_cache, ttl_check_interval: false]},
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
