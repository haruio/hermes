defmodule HApi.PushService do
  alias HApi.Push
  alias HApi.Push.Query, as: PushQuery
  alias HApi.Service.Query, as: ServiceQuery
  alias Util.KeyGenerator
  alias Util.PushProducer
  alias Code.PushStatus

  def send_push(service, param) do
    # set service_id, push_id
    param = param
    |> build_param(Map.get(service, "service_id"))

    # save push
    push = via_push_model({:send_push, param})
    |> insert_push

    # select service config
    service = push
    |> Map.get(:service_id)
    |> ServiceQuery.select_one_by_service_id

    # publish to queue
    build_message(push, service,  Map.get(param, "pushTokens", []))
    |> PushProducer.publish

    # send response
    Map.take(param, ["pushId"])
  end

  def reserve_push(service, param) do
    # set service_id, push_id
    param = param
    |> build_param(Map.get(service, "service_id"))
    |> Map.put("pushStatus", PushStatus.cd_reserved)

    # save push
    via_push_model({:reserve_push, param})
    |> insert_push

    # publish to scheduler
    PushProducer.reserve(param)

    # send response
    Map.take(param, ["pushId"])
  end

  def create_message(service, param) do
    # set service_id, push_id
    param = param
    |> build_param(Map.get(service, "service_id"))

    # save push
    via_push_model({:reserve_push, param})
    |> insert_push

    # return push id
    Map.take(param, ["pushId"])
  end

  def create_reserve_message(service, param) do
    # set service_id, push_id
    param = param
    |> build_param(Map.get(service, "service_id"))
    |> Map.put("pushStatus", PushStatus.cd_reserved)

    # save push
    via_push_model({:reserve_push, param})
    |> insert_push

    # return push id
    Map.take(param, ["pushId"])
  end

  def send_token(service, param) do
    # get push message
    push = param
    |> Map.get("pushId")
    |> PushQuery.select_one_by_push_id

    # select service config
    service = push
    |> Map.get(:service_id)
    |> ServiceQuery.select_one_by_service_id

    # publish push or scheduler
    result = case Map.get(push, "push_status") do
               "RVED" ->
                 Map.get(push, :service_id)
                 PushProducer.reserve_add_token
               nil ->
                 {:error, "Invalid push id"}
               _ ->
                 build_message(push, service, Map.get(param, :pushTokens, []))
                 |> PushProducer.publish(push)
             end

    # retun push id
    %{"method" => "send_toekn"}
  end

  ## Private method
  defp build_param(param, service_id) do
    param
    |> Map.put("serviceId", service_id)
    |> Map.put("pushId", create_push_id(service_id))
  end

  defp build_message(push_model, service_model, tokens) do
    push_model
    |> Map.take([:push_id, :service_id, :title, :body])
    |> Map.put(:pushTokens, tokens)
    |> Map.merge(Map.take(service_model, [:gcm_api_key, :apns_key, :apns_cert]))
  end

  defp insert_push(model) do
    Push.changeset(%Push{}, model)
    |> PushQuery.insert
  end

  defp create_push_id(service_id) do
    :random.seed :os.timestamp
    [ service_id, KeyGenerator.gen_timebased_key, Enum.take_random(?a..?z, 5) ]
    |> Enum.join "-"
  end

  defp via_push_model({:reserve_push, param}), do: via_push_model({:send_push, param})
  defp via_push_model({:create_message, param}), do: via_push_model({:send_push, param})
  defp via_push_model({:send_push, param}) do
    %{
      "service_id" => Map.get(param, "serviceId"),
      "push_id" => Map.get(param, "pushId"),
      "push_condition" => Map.get(param, "condition", %{}) |> Poison.encode!,
      "push_status" => Map.get(param, "pushStatus", PushStatus.cd_approved),
      "publish_start_dt" => Map.get(param, "publishStartDt"),
      "publish_end_dt" => Map.get(param, "publishEndDt"),
      "body" => Map.get(param, "message") |> Map.get(param, "body"),
      "title" => Map.get(param, "message") |> Map.get(param, "title"),
      "extra" => Map.get(param, "extra") |> Poison.encode!,
      "create_user" => Map.get(param, "createUser", 1),
      "update_user" => Map.get(param, "updateUser", 1)
    }
  end
end
