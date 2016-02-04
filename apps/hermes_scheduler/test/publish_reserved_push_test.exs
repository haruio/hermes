defmodule PublishReservedPushTest do
  use ExUnit.Case

  alias HScheduler.Job.PublishReservedPush
  alias HScheduler.Store.PushTokenStore

  test "publish test" do
    PublishReservedPush.do_job
  end
end
