defmodule HPush.Provider.ProviderSup do
  use Supervisor

  def start_link(args \\ []), do: Supervisor.start_link(__MODULE__, args, [name: ProviderSup])
  def init(args) do
    children =[
      supervisor(HPush.Provider.GCMProviderSup, []),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
