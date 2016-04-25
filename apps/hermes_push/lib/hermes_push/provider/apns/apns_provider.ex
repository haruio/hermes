defmodule HPush.Provider.APNSProvider do
  use ExActor.GenServer
  alias HPush.Model.PushStats, as: PushStats

  require Logger

  @default_feedback Application.get_env(:hermes_push, :feedback, "http://52.76.122.168:9090")

  alias HPush.Provider.APNSConnectionRepository, as: ConnRepo

  def pool_name, do: APNSProviderPool

  defstart start_link(args \\ %{}), do: initial_state(args)
  def publish(message, tokens) do
    Logger.debug "[#{__MODULE__}] publish"

    :poolboy.transaction(pool_name, &(GenServer.cast(&1, {:publish, message, tokens})))
  end

  defcast publish(message, tokens), state: state do
    Logger.debug "[#{__MODULE__}] handle_cast  publish"
    {:ok, pool_name} = ConnRepo.get_repository(message)
    Logger.debug "[#{__MODULE__}] get_repository = #{pool_name}"

    payload = build_payload(message)
    Logger.debug "[#{__MODULE__}] handle_cast  publish APNS.push"
    tokens
    |> Enum.with_index
    |> Enum.each(fn({token, i}) ->
      {:ok, queue} = HQueue.Queue.declare(pool_name)
      HQueue.Queue.publish(queue, Map.put(payload, :token, token))
    end)

    ## TODO send feedback
    Logger.info "[#{__MODULE__}] handle_cast  publish HPush.StatsChecker.add"
    HPush.StatsChecker.add(%{push_id: message[:push_id],
                             ststs_cd: PushStats.cd_published,
                             stats_cnt: length(tokens),
                             stats_start_dt: Ecto.DateTime.utc,
                             stats_end_dt: Ecto.DateTime.utc})
    noreply
  end

  def build_payload(message, feedback \\ @default_feedback) do
    APNS.Message.new
    |> Map.put(:alert, Map.get(message, :body))
    |> Map.put(:badge, 1) ## TODO apns_option
    |> Map.put(:extra, message |> build_extra_data(feedback))
  end


  def build_extra_data(nil), do: %{}
  def build_extra_data(message, feedback) do
    {:ok, extra} = Map.get(message, :extra) |> Poison.decode

    Map.drop(extra, ["android", "ios"])
    |> Map.merge(Map.get(extra, "ios", %{}))
    |> Map.put("pushId", Map.get(message, :push_id))
    |> Map.put("feedback", feedback)
  end
end
