use Mix.Config

config :smartmeter, SmartmeterWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  load_from_system_env: true,
  url: [host: "localhost", port: {:system, "PORT"}],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:smartmeter, :vsn)

config :logger, level: :info

config :smartmeter, Smartmeter.InfluxConnection,
  database:  "smartmeter_measurements",
  host: "grafana.addictivesoftware.net",
  pool: [max_overflow: 10, size: 50],
  port: 8086,
  scheme: "http",
  writer: Instream.Writer.Line

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
# config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
config :smartmeter, SmartmeterWeb.Endpoint, server: true


# Finally import the config/prod.secret.exs
# which should be versioned separately.
import_config "prod.secret.exs"
