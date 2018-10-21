# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :smartmeter,
  ecto_repos: [Smartmeter.Repo]

# Configures the endpoint
config :smartmeter, SmartmeterWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lExkI0YelUEWxhsTgBhHWTZxVZvOxmpmYp+9ycUeqyG7kaZj1C5xMp4sfu7i+Qj/",
  render_errors: [view: SmartmeterWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Smartmeter.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]


config :smartmeter, Smartmeter.InfluxConnection,
  init: {InfluxInit, :init}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
