defmodule HPush.Provider.APNSProvider do
  use ExActor.GenServer
  alias HPush.Model.PushStats, as: PushStats

  @default_feedback "http://52.76.122.168:9090"

  alias HPush.Provider.APNSConnectionRepository, as: ConnRepo

  def pool_name, do: APNSProviderPool

  defstart start_link(args \\ %{}), do: initial_state(args)
  def publish(message, tokens), do: :poolboy.transaction(pool_name, &(GenServer.cast(&1, {:publish, message, tokens})))
  defcast publish(message, tokens), state: state do
    {:ok, pool_name} = ConnRepo.get_repository(message)

    payload = build_payload(message)
    Enum.each(tokens, &(APNS.push(pool_name, Map.put(payload, :token, &1))))

    ## TODO send feedback

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