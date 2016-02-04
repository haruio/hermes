defmodule CancelReservedPushTest do
  use ExUnit.Case

  alias HScheduler.Store.StoreSup
  alias HScheduler.Job.CancelReservedPush

  test "cancel" do
    CancelReservedPush.do_job

  end
end
