use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :hermes_api, HApi.Endpoint,
  http: [port: 2000],
  debug_errors: false,
  code_reloader: false,
  cache_static_lookup: false,
  check_origin: false,
  watchers: []
  render_errors: [default_format: "json"]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :hermes_api, HApi.Repo,
adapter: Ecto.Adapters.MySQL,
username: "root",
password: "foretouch919293",
database: "mks_hermes",
hostname: "127.0.0.1",
pool_size: 5

config :hermes_api, Producer.PushProducer,
adapter: Producer.Router.LocalPushRouter
