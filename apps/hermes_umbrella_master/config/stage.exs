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
level: :info,
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
hostname: "54.64.129.13",
port: 16603,
pool_size: 5

config :hermes_push, HPush.Repo,
adapter: Ecto.Adapters.MySQL,
username: "makeus_hermes",
password: "apdlzjtm20!%gpfmaptm",
database: "mks_hermes",
hostname: "54.64.129.13",
port: 16603,
pool_size: 5

config :hermes_scheduler, HScheduler.Repo,
adapter: Ecto.Adapters.MySQL,
username: "makeus_hermes",
password: "apdlzjtm20!%gpfmaptm",
database: "mks_hermes",
hostname: "54.64.129.13",
port: 16603,
pool_size: 5

config :apns,
callback_module:    APNS.Callback,
timeout:            30,
feedback_interval:  1200,
reconnect_after:    1000,
support_old_ios:    true,
pools: [ ]

config :hermes_push, feedback: "http://52.76.122.168:9090"

# feedback url
config :hermes_push, HPush.Feedback,
delete: ["post", "http://0-kr-api.dingo.tv/dingo/v1/admin/pushtoken/delete"],
update: ["put", "http://0-kr-api.dingo.tv/dingo/v1/admin/pushtoken"]



config :hermes_api, Producer.PushProducer,
adapter: Producer.Router.LocalPushRouter

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
