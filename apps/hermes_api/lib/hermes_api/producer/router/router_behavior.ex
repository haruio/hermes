defmodule Producer.Router.RouterBehavior do
  @type message :: atom

  @callback publish_immediate(message) :: any
  @callback publish_reserve(message) :: any
  @callback new :: any
end
