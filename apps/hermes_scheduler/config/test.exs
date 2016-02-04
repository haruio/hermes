use Mix.Config

config :hermes_scheduler, HScheduler.Repo,
adapter: Ecto.Adapters.MySQL,
username: "root",
password: "foretouch919293",
database: "mks_hermes",
hostname: "127.0.0.1",
pool_size: 5

config :hermes_scheduler, HScheduler.Store.PushTokenStore,
adapter: HScheduler.Store.ETSAdapter,
name: :push_reserved_store,
opts: [:public, :duplicate_bag]
