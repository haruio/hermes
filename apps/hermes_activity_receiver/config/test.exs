use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hermes_activity_receiver, HActivity.Endpoint,
  http: [port: 9000],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :hermes_activity_receiver, HActivity.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "foretouch919293",
  database: "mks_hermes",
  hostname: "127.0.0.1",
  pool: Ecto.Adapters.SQL.Sandbox


config :hermes_activity_receiver, Splunk,
host: 'mailfeed.makeusmobile.com',
port: 9998,
opts: [:binary, active: false]
