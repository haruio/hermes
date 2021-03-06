use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :hermes_activity_receiver, HActivity.Endpoint,
  http: [port: 9000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: []

# Watch static and templates for browser reloading.
config :hermes_activity_receiver, HActivity.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :hermes_activity_receiver, HActivity.Repo,
adapter: Ecto.Adapters.MySQL,
username: "root",
password: "foretouch919293",
database: "mks_hermes",
hostname: "127.0.0.1",
pool_size: 5

config :hermes_activity_receiver, Splunk,
host: 'mailfeed.makeusmobile.com',
port: 9998,
opts: [:binary, active: false]
