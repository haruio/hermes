defmodule Producer.PushProducer do
  use ExActor.GenServer, export: __MODULE__

  defstart start_link, do: initial_state(Application.get_env(:hermes_api, __MODULE__))

  defcast publish_immediate(message), state: state do
    route = state[:adapter]
    route.publish_immediate(message)

    noreply
  end

  defcast publish_reserve(message), state: state do
    route = state[:adapter]
    route.publish_reserve(message)

    noreply
  end
end
