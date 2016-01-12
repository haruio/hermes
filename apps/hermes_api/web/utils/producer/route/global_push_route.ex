defmodule Producer.Route.GlobalPushRoute do
  @behavior Producer.Route.RouteBehavior

  def publish_immediate(message) do
    IO.puts "global route immediate"
  end

  def publish_reserve(message) do
    IO.puts "global route reserve"
  end
end
