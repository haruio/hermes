defmodule SplunkTest do
  use ExUnit.Case

  test "connect test" do
    {:ok, splunk} = Application.get_env(:hermes_activity_receiver, Splunk)
    |> Splunk.start_link

    assert is_pid(splunk)
  end

  test "connection pool" do
    {:ok, splunk_pool} = Application.get_env(:hermes_activity_receiver, Splunk)
   |> Splunk.ConnectionPool.start_link

    assert is_pid(splunk_pool)
  end

end
