defmodule HApi.PushService do
  alias HApi.Push
  alias HApi.Push.Query, as: PushQuery
  alias Util.KeyGenerator
  alias Producer.PushProducer
  alias Code.PushStatus

  def publish_push(:immediate, service, param) do
    # set service_id, push_id
    param = param
    |> build_param(Map.get(service, :service_id))

    # save push
    push = via_push_model({:send_push, param})
    |> insert_push

    # publish to queue
    message = build_message(push, service,  Map.get(param, "pushTokens", []))
    PushProducer.publish_immediate(message)

    # send response
    Map.take(param, ["pushId"])
  end

  def publish_push(:reserve, service, param) do
    # set service_id, push_id
    param = param
    |> build_param(Map.get(service, :service_id))
    |> Map.put("pushStatus", PushStatus.cd_reserved)

    # save push
    push = via_push_model({:reserve_push, param})
    |> insert_push

    # publish to scheduler
    message = build_reserve_message(param)
    PushProducer.publish_reserve({:reserve, message})

    # send response
    Map.take(param, ["pushId"])
  end

  def create_message(:immediate, service, param) do
    # set service_id, push_id
    param = param
    |> build_param(Map.get(service, :service_id))

    # save push
    via_push_model({:create_message, param})
    |> insert_push

    # return push id
    Map.take(param, ["pushId"])
  end

  def create_message(:reserve, service, param) do
    # set service_id, push_id
    param = param
    |> build_param(Map.get(service, :service_id))
    |> Map.put("pushStatus", PushStatus.cd_reserved)

    # save push
    via_push_model({:create_reserve_message, param})
    |> insert_push

    # publish to scheduler
    message = build_reserve_message(param)
    PushProducer.publish_reserve({:reserve, message})

    # return push id
    Map.take(param, ["pushId"])
  end


  def send_token(service, param) do
    # get push message
    push = param
    |> Map.get("pushId")
    |> PushQuery.select_one_by_push_id

    cond do
      Map.get(push, :push_status) == PushStatus.cd_reserved ->
        send_token(:reserve, service, param, push)
      true ->
        send_token(:immediate, service, param, push)
    end
  end

  def send_token(:immediate, service, param, push) do
    # publish push
    message = build_message(push, service,  Map.get(param, "pushTokens", []))

    # publish message
    PushProducer.publish_immediate(message)

    # retun push id
    Map.take(param, ["pushId"])
  end

  def send_token(:reserve, service, param, push) do
    # build message
    message = build_reserve_message(param)

    # publish message
    PushProducer.publish_reserve({:reserve, message})

    # return push id
    Map.take(param, ["pushId"])
  end

  ## Private method
  defp build_param(param, service_id) do
    param
    |> Map.put("serviceId", service_id)
    |> Map.put("pushId", create_push_id(service_id))
  end

  defp build_message(push_model, service_model, tokens) do
    push_model
    |> Map.take([:push_id, :service_id, :title, :body, :publish_time, :extra])
    |> Map.put(:push_tokens, tokens)
    |> Map.put(:apns_env, :dev) ## TODO apns_options
    |> Map.merge(Map.take(service_model, [:gcm_api_key, :apns_key, :apns_cert]))
  end

  defp build_reserve_message(param) when is_map(param), do: build_reserve_message(Map.get(param, "pushId"), Map.get(param, "pushTokens"))
  defp build_reserve_message(%HApi.Push{push_id: push_id}, tokens), do: build_reserve_message(push_id, tokens)
  defp build_reserve_message(push_id, tokens \\ :empty) when is_binary(push_id) do
    case tokens do
      :empty -> %{push_id: push_id}
      _ -> %{push_id: push_id, push_tokens: tokens}
    end
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
  defp via_push_model({:create_reserve_message, param}), do: via_push_model({:send_push, param})
  defp via_push_model({:send_push, param}) do
    now = Ecto.DateTime.utc
    %{
      "service_id" => Map.get(param, "serviceId"),
      "push_id" => Map.get(param, "pushId"),
      "push_condition" => Map.get(param, "condition", %{}) |> Poison.encode!,
      "push_status" => Map.get(param, "pushStatus", PushStatus.cd_approved),
      "publish_dt" => Map.get(param, "publishTime", now) |> timestamp_to_ecto_datetime,
      "publish_start_dt" => Map.get(param, "publishStartDt"),
      "publish_end_dt" => Map.get(param, "publishEndDt"),
      "body" => Map.get(param, "message") |> Map.get("body"),
      "title" => Map.get(param, "message") |> Map.get("title"),
      "extra" => Map.get(param, "extra") |> Poison.encode!,
      "create_user" => Map.get(param, "createUser", 1),
      "create_dt" => Map.get(param, "create_dt", now),
      "update_user" => Map.get(param, "updateUser", 1),
      "update_dt" => Map.get(param, "update_dt", now)
    }
  end

  defp timestamp_to_ecto_datetime(obj) when is_map(obj) , do: obj
  defp timestamp_to_ecto_datetime(timestamp) when is_integer(timestamp), do: timestamp |> Calendar.DateTime.Parse.js_ms!
end
