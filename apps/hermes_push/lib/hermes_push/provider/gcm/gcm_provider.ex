defmodule HPush.Provider.GCMProvider do
  use ExActor.GenServer
  alias HPush.Model.PushStats.Query, as: PushStatsQuery
  alias HPush.Model.PushStats, as: PushStats

  @default_feedback Application.get_env(:hermes_push, :feedback, "http://52.76.122.168:9090")

  def pool_name , do: GCMProviderPool

  defstart start_link(args \\ %{}), do: initial_state(args)
  defcast publish(message, tokens), state: state do
    gcm_key = Map.get(message, :gcm_api_key)
    {:ok, gcm_res} = GCM.push(gcm_key, tokens, build_payload(message))

    ## TODO send feedback

    HPush.StatsChecker.add(%{push_id: message[:push_id],
                            ststs_cd: PushStats.cd_published,
                            stats_cnt: length(tokens),
                            stats_start_dt: Ecto.DateTime.utc,
                            stats_end_dt: Ecto.DateTime.utc})

    noreply
  end

  def publish(message, tokens) do
    :poolboy.transaction(pool_name, fn(provider) ->
      GenServer.cast(pool_name, {:publish, message, tokens})
    end)
  end


  def build_payload(message, feedback \\ @default_feedback ) do
    %{
      "notification" => Map.take(message, [:title, :body]),
      "data" => build_extra_data(message, feedback)
    }
  end

  def buid_extra_data(nil), do: %{}
  def build_extra_data(message, feedback) when is_map(message), do: build_extra_data(Map.get(message, :push_id), Map.get(message, :extra, nil), feedback)
  def build_extra_data(push_id, extra, feedback) when is_binary(extra) do
    {:ok, extra} = Poison.decode(extra)

    Map.drop(extra, ["android", "ios"])
    |> Map.merge(Map.get(extra, "android", %{}))
    |> Map.put("pushId", push_id)
    |> Map.put("feedback", feedback)
  end
end
