defmodule HScheduler.Store.StoreSup do
  use Supervisor

  alias HScheduler.Store.PushTokenStore

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, [name: __MODULE__])

  def init(:ok) do
    push_token_store_opts = Application.get_env(:hermes_scheduler, PushTokenStore)
    children = [
      worker(PushTokenStore, [push_token_store_opts])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
