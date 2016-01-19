defmodule Producer.Route.RouteBehavior do
  @type message :: atom

  @callback publish_immediate(message) :: any
  @callback publish_reserve(message) :: any
end
