defmodule HPush.Provider.APNSConnectionPoolMan do
  use GenServer

  require Logger

  defmodule State do
    defstruct q_name: nil, q: nil, q_ref: nil
  end

  def start_link(q_name) do
    GenServer.start_link(__MODULE__, {q_name})
  end

  def init({q_name}) do
    {:ok, q} = HQueue.Queue.declare(q_name)
    q_ref = Process.monitor(q)

    send self, :consume
    {:ok, %State{q_name: q_name, q: q, q_ref: q_ref}}
  end

  ## Callback API
  def handle_info(:consume, %State{q: q, q_name: q_name}=state) do
    {msg_id, message} = HQueue.Queue.consume(q)
    case APNS.push(q_name, message) do
      :ok -> HQueue.Queue.ack(q, msg_id)
      error ->
        Logger.error "#{inspect error}"
    end
    Process.send_after(self, :consume, 35)
    {:noreply, state}
  end

  def handle_call(:timeout, %State{q: q, q_name: q_name}=state) do
    Logger.error "[#{__MODULE__}] timeout"
    Process.send_after(self, :consume, 1000)
    {:noreply, state}
  end
end
