defmodule Producer.Route.LocalPushRoute do
  @behavior Producer.Route.RouteBehavior

  def publish_immediate(message) do
    IO.puts "local route immediate"
  end

  def publish_reserve(message) do
    IO.puts "local route reserve"
  end
end
