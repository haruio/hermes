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
    push = via_push_model({:new, param})
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
    push = via_push_model({:new, param})
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
    via_push_model({:new, param})
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
    via_push_model({:new, param})
    |> insert_push

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

  def cancel_reserved(service, param) do
    push_id = Map.get(param, "id")
    push = PushQuery.select_one_by_push_id(push_id)

    if push.push_status == PushStatus.cd_reserved do
      changeset = Push.changeset(push, %{push_status: PushStatus.cd_canceling})
      case PushQuery.update(changeset) do
        {:ok, _} ->
          PushProducer.cancel_reserved(push_id)
          send_ok
        {:error, _} -> send_error
      end
    else
      send_error(%{"message" => "Invalid push status"})
    end
  end

  def send_immediate(service, param) do
    push_id = Map.get(param, "id")
    push = PushQuery.select_one_by_push_id(push_id)

    if push.push_status == PushStatus.cd_reserved do
      changeset = Push.changeset(push, %{publish_dt: Ecto.DateTime.utc})
      case PushQuery.update(changeset) do
        {:ok, _} ->
          PushProducer.cancel_reserved(push_id)
          send_ok
        {:error, _} -> send_error
      end
    else
      send_error(%{"message" => "Invalid push status"})
    end
  end

  def update_reserved(service, param) do
    push_id = Map.get(param, "id")
    push = PushQuery.select_one_by_push_id(push_id)

    cond do
      push == nil -> send_error(%{"message" => "Invalid push id"})
      push.push_status == PushStatus.cd_reserved ->
        model = via_push_model({:update, param})
        |> Map.take ["publish_dt", "title", "body", "extra"]

        Push.changeset(push, model)
        |> PushQuery.update

        send_ok
      true -> send_error(%{"message" => "Invalid push status"})
    end
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

  defp send_ok(obj \\ %{}), do: Map.merge(%{"status" => "ok"}, obj)
  defp send_error(obj \\ %{}), do: Map.merge(%{"status" => "error"}, obj)

  defp create_push_id(service_id) do
    :random.seed :os.timestamp
    [ service_id, KeyGenerator.gen_timebased_key, Enum.take_random(?a..?z, 5) ]
    |> Enum.join "-"
  end

  defp via_push_model({:new, param}) do
    now = Ecto.DateTime.utc
    param
    |> Map.put("createDt", now)
    |> Map.put("updateDt", now)
    |> Map.put("publishTime", Map.get(param, "publishTime", now))
    |> via_push_model
  end
  defp via_push_model({:update, param})  do
    param
    |> Map.put("update_dt", Ecto.DateTime.utc)
    |> via_push_model
  end
  defp via_push_model(param) when is_map(param) do
    %{
      "service_id" => Map.get(param, "serviceId"),
      "push_id" => Map.get(param, "pushId"),
      "push_condition" => Map.get(param, "condition", %{}) |> Poison.encode!,
      "push_status" => Map.get(param, "pushStatus", PushStatus.cd_approved),
      "publish_dt" => Map.get(param, "publishTime") |> timestamp_to_ecto_datetime,
      "publish_start_dt" => Map.get(param, "publishStartDt"),
      "publish_end_dt" => Map.get(param, "publishEndDt"),
      "body" => Map.get(param, "message") |> Map.get("body"),
      "title" => Map.get(param, "message") |> Map.get("title"),
      "extra" => Map.get(param, "extra") |> Poison.encode!,
      "create_user" => Map.get(param, "createUser", 1),
      "create_dt" => Map.get(param, "createDt"),
      "update_user" => Map.get(param, "updateUser", 1),
      "update_dt" => Map.get(param, "updateDt")
    }
  end

  defp timestamp_to_ecto_datetime(nil), do: nil
  defp timestamp_to_ecto_datetime(obj) when is_map(obj) , do: obj
  defp timestamp_to_ecto_datetime(timestamp) when is_integer(timestamp), do: timestamp |> Calendar.DateTime.Parse.js_ms!
end
