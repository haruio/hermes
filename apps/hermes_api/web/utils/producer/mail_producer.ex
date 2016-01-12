defmodule Producer.MailProducer do
  use ExActor.GenServer, export: __MODULE__

  defstart start_link , do: initial_state(0)

  defcast publish(message) do
    noreply
  end

  defcast reserve(message) do
    noreply
  end

  defcast reserve_add_token(push_id, tokens) do
    noreply
  end

end
