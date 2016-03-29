defmodule HPush.FeedbackMan do
  use GenServer

  @init_state %{}

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, @init_state}
  end


  def feedback(:gcm, message, tokens) do
    GenServer.cast(__MODULE__, {:gcm, message, tokens})
  end

  def feedback(:apns, message) do
    GenServer.cast(__MODULE__, {:apns, message})
  end


  ## Callback API
  def handle_cast({:gcm, message, tokens}, state) do
    :poolboy.transaction(HPush.Feedback, fn(sender) ->
      HPush.Feedback.feedback(sender, {:gcm, message, tokens})
    end)
    {:noreply, state}
  end

  def handle_cast({:apns, message}, state) do
    :poolboy.transaction(HPush.Feedback, fn(sender) ->
      HPush.Feedback.feedback(sender, {:apns, message})
    end)
    {:noreply, state}
  end
end
