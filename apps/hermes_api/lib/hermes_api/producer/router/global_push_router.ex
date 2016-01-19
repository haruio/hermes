defmodule Producer.Router.GlobalPushRouter do
  @behavior Producer.Router.RouterBehavior

  def new do

  end

  def publish_immediate(message) do
    IO.puts "global route immediate"
  end

  def publish_reserve(message) do
    IO.puts "global route reserve"
  end
end
