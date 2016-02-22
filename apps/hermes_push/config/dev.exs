use Mix.Config

config :apns,
callback_module:    APNS.Callback,
timeout:            30,
feedback_interval:  1200,
reconnect_after:    1000,
support_old_ios:    true,
pools: [ ]

config :hermes_push, HPush.Repo,
adapter: Ecto.Adapters.MySQL,
username: "root",
password: "foretouch919293",
database: "mks_hermes",
hostname: "127.0.0.1",
pool_size: 5

config :hermes_push, HPush.Provider.GCMProvider,
feedback: "http://52.76.122.168:9090"

config :hermes_push, HPush.Provider.APNSProvider,
feedback: "http://52.76.122.168:9090"

config :hermes_push, HPush.Dispatcher,
apn: HPush.Provider.APNSProvider,
gcm: HPush.Provider.GCMProvider
