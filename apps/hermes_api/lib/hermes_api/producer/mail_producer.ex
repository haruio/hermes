defmodule Producer.MailProducer do
  use ExActor.GenServer

  defstart start_link(args \\ []), do: initial_state(args)

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
