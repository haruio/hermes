defmodule HActivity.PushFeedbackService do
  alias HActivity.StatsChecker

  def received(message) do
    message
    |> StatsChecker.add

    %{result: "received"}
  end

  def opened(message) do
    message
    |> StatsChecker.add

    %{result: "opened"}
  end
end
