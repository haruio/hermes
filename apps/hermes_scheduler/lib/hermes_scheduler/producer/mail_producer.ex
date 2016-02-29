defmodule HScheduler.Producer.MailProducer do
  use ExActor.GenServer

  def pool_name, do: __MODULE__

  defstart start_link(args \\ []), do: initial_state(args)
end
