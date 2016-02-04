defmodule PushTokenStoreTest do
  use ExUnit.Case, async: false

  alias HScheduler.Store.PushTokenStore, as: Store

  # test "select all" do
  #   Store.add("3", ["3", "4", "5"])
  #   Store.add("3", ["6", "7", "8"])
  #   Store.add("3", ["9", "10", "11"])

  #   Store.add("4", ["a", "b", "c"])
  #   Store.add("4", ["6a", "7b", "8c"])
  #   Store.add("4", ["9a", "10b", "11c"])


  #   assert [["3", "4", "5"],["6", "7", "8"],["9", "10", "11"]] == Store.select_all("3")
  # end
end
