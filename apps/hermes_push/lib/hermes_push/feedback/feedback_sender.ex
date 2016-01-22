defmodule HPush.Feedback.FeedbackSender do
  def send_feedback({:gcm, deleted_tokens, updated_tokens}), do: :ok
end
