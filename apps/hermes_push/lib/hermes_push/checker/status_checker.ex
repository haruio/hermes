defmodule HPush.StatusCheker do
  use ExActor.GenServer, export: __MODULE__
  alias HPush.Model.Push
  alias HPush.Model.Push.Query, as: PushQuery

  defstart start_link(args \\ %{}) do
    initial_state(args)
  end

  defcast check(push_id, len_token), state: state do
    {_request_cnt, push} = get_push(push_id, state[push_id])
    |> Map.take([:push_id, :request_cnt])
    |> Map.get_and_update!(:request_cnt, fn(current) -> {current, current-len_token} end)

    if push[:request_cnt] <=  0 do
      PushQuery.update([push_id: push_id], push_status: "PUED", publish_end_dt: Ecto.DateTime.utc)
      Map.delete(state, push_id)
    else
      Map.put(state, push_id, push)
    end
    |> new_state

  end

  defp get_push(push_id, nil) do
    push = PushQuery.select_one_by_push_id(push_id)

    push
    |> Push.changeset(%{push_status: "PUING", publish_start_dt: Ecto.DateTime.utc})
    |> PushQuery.update

    push
  end
  defp get_push(push_id, push), do: push
end
