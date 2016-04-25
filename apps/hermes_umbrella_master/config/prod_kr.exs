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
  watchers: [],
  server: true,
  render_errors: [default_format: "json"]

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  format: "[$level] $message\n",
  backends: [:console],
  handle_sasl_reports: true,
  handle_otp_reports: true,
  level: :error,
  compile_time_purge_level: :error

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :hermes_api, HApi.Repo,
adapter: Ecto.Adapters.MySQL,
username: "makeus_hermes",
password: "apdlzjtm20!%gpfmaptm",
database: "mks_hermes",
port: 16603,
hostname: "10.10.1.5",
keepalive: true,
pool_size: 2

config :hermes_push, HPush.Repo,
adapter: Ecto.Adapters.MySQL,
username: "makeus_hermes",
password: "apdlzjtm20!%gpfmaptm",
database: "mks_hermes",
port: 16603,
hostname: "10.10.1.5",
keepalive: true,
pool_size: 2

config :hermes_scheduler, HScheduler.Repo,
adapter: Ecto.Adapters.MySQL,
username: "makeus_hermes",
password: "apdlzjtm20!%gpfmaptm",
database: "mks_hermes",
port: 16603,
hostname: "10.10.1.5",
keepalive: true,
pool_size: 2

config :hermes_api, Producer.PushProducer,
adapter: Producer.Router.LocalPushRouter

config :apns,
callback_module:    APNS.Callback,
timeout:            30,
feedback_interval:  1200,
reconnect_after:    1000,
support_old_ios:    true,
pools: [ ]

# activity log url
config :hermes_push, feedback: "http://220.90.203.114:8000"

# feedback url
config :hermes_push, HPush.Feedback,
delete: ["post", "http://0-kr-api.dingo.tv/dingo/v1/admin/pushtoken/delete"],
update: ["put", "http://0-kr-api.dingo.tv/dingo/v1/admin/pushtoken"]

config :hermes_push, HPush.Dispatcher,
apn: HPush.Provider.APNSProvider,
gcm: HPush.Provider.GCMProvider

config :hermes_scheduler, HScheduler.Store.PushTokenStore,
adapter: HScheduler.Store.ETSAdapter,
name: :push_reserved_store,
opts: [:public, :duplicate_bag]

config :quantum, cron: [
  "* * * * * HScheduler.Job.PublishReservedPush.do_job",
  "*/3 * * * * HScheduler.Job.CancelReservedPush.do_job",
],
default_overlap: false

## activity log
config :hermes_activity_receiver, HActivity.Endpoint,
http: [port: 8000],
debug_errors: false,
code_reloader: false,
cache_static_lookup: false,
check_origin: false,
server: true,
watchers: []

config :hermes_activity_receiver, HActivity.Repo,
adapter: Ecto.Adapters.MySQL,
username: "makeus_hermes",
password: "apdlzjtm20!%gpfmaptm",
database: "mks_hermes",
port: 16603,
hostname: "10.10.1.5",
keepalive: true,
pool_size: 2

config :hermes_activity_receiver, Splunk,
host: '220.90.203.111',
port: 9990
