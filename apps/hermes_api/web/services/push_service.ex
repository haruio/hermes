defmodule HApi.PushService do
  alias HApi.Push
  alias HApi.Push.Query, as: PushQuery
  alias HApi.PushStats.Query, as: PushStatsQuery
  alias HApi.PushOption.Query, as: PushOptionQuery
  alias Util.KeyGenerator
  alias Producer.PushProducer
  alias Code.PushStatus

  def publish_push(:immediate, service, param) do
    # set service_id, push_id
    param = param
    |> build_param(Map.get(service, :service_id))

    # save push
    push = via_push_model({:new, param})
    |> PushQuery.insert_model

    # save push options
    options = via_push_option_models(param)
    |> Enum.map(&PushOptionQuery.insert_model/1)

    # publish to queue
    build_message(push, service, options, Map.get(param, "pushTokens", []))
    |> PushProducer.publish_immediate

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
    |> PushQuery.insert_model

    # save push options
    options = via_push_option_models(param)
    |> Enum.map(&PushOptionQuery.insert_model/1)

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
    |> PushQuery.insert_model

    # save push options
    options = via_push_option_models(param)
    |> Enum.map(&PushOptionQuery.insert_model/1)

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
    |> PushQuery.insert_model

    # save push options
    options = via_push_option_models(param)
    |> Enum.map(&PushOptionQuery.insert_model/1)

    # return push id
    Map.take(param, ["pushId"])
  end


  def send_token(service, param) do
    case PushQuery.select_one_by_push_id(param["pushId"]) do
      nil -> {:error, "Invalid push id"}
      push ->
        cond do
          Map.get(push, :push_status) == PushStatus.cd_reserved ->
            send_token(:reserve, service, param, push)
          true ->
            send_token(:immediate, service, param, push)
        end
    end
  end

  def send_token(:immediate, service, param, push) do
    # select push options
    options = PushOptionQuery.select(push_id: param["pushId"])

    # publish push
    message = build_message(push, service, options, Map.get(param, "pushTokens", []))

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

    case PushQuery.select_one_by_push_id(push_id) do
      nil -> {:error, "Invalid push id"}
      push ->
        if push.push_status == PushStatus.cd_reserved do
          changeset = Push.changeset(push, %{push_status: PushStatus.cd_canceling})
          case PushQuery.update(changeset) do
            {:ok, _} -> PushProducer.cancel_reserved(push_id)
            {:error, _} = error-> error
          end
        else
          {:error, "Invalid push status"}
        end
    end
  end

  def send_immediate(service, param) do
    push_id = Map.get(param, "id")

    case PushQuery.select_one_by_push_id(push_id) do
      nil -> {:error, "Invalid push id"}
      push ->
        if push.push_status == PushStatus.cd_reserved do
          now = Ecto.DateTime.utc
          changeset = Push.changeset(push, %{publish_dt: now, publish_start_dt: now})
          case PushQuery.update(changeset) do
            {:ok, _} -> PushProducer.cancel_reserved(push_id)
            {:error, _} = error -> error
          end
        else
          {:error, "Invalid push status"}
        end
    end
  end

  def update_reserved(service, param) do
    push_id = Map.get(param, "id")

    case PushQuery.select_one_by_push_id(push_id) do
      nil -> {:error, "Invalid push id"}
      push ->
        cond do
          push.push_status == PushStatus.cd_reserved ->
            model = via_push_model({:update, param})
            |> Map.take ["publish_dt", "title", "body", "extra"]

            Push.changeset(push, model)
            |> PushQuery.update
          true -> {:error, "Invalid push status"}
        end
    end
  end

  def get_push_list(service, param) do
    PushQuery.select([service_id: service.service_id], Map.take(param, ["page", "pageSize"]))
    |> via_push_page_dto
  end

  def get_push(service, param = %{"id" => id}) do
    case PushQuery.select_one([push_id: id]) do
      nil -> {:error, "Invalid push id"}
      model -> via_push_dto(model)
    end
  end

  ## Private method
  defp build_param(param, service_id) do
    param
    |> Map.put("serviceId", service_id)
    |> Map.put("pushId", create_push_id(service_id))
  end


  defp build_message(push_model, service_model, option_models, tokens) do
    options = option_models |> build_options

    push_model
    |> Map.take([:push_id, :service_id, :title, :body, :publish_time, :extra])
    |> Map.put(:push_tokens, tokens)
    |> Map.put(:options, options)
    |> Map.put(:gcm_api_key, Map.get(service_model,:gcm_api_key))
    |> Map.merge(get_apns_key(service_model, options[:apns]["env"]))
  end

  def get_apns_key(service_model, "dev") do
    %{
      apns_key: Map.get(service_model, :apns_dev_key),
      apns_cert: Map.get(service_model, :apns_dev_cert)
    }
  end
  def get_apns_key(service_model, "prod") do
    %{
      apns_key: Map.get(service_model, :apns_key),
      apns_cert: Map.get(service_model, :apns_cert)
    }
  end
  def get_apns_key(service_model, nil), do: get_apns_key(service_model, "dev")

  defp build_reserve_message(param) when is_map(param), do: build_reserve_message(Map.get(param, "pushId"), Map.get(param, "pushTokens"))
  defp build_reserve_message(%HApi.Push{push_id: push_id}, tokens), do: build_reserve_message(push_id, tokens)
  defp build_reserve_message(push_id, tokens \\ :empty) when is_binary(push_id) do
    case tokens do
      :empty -> %{push_id: push_id}
      _ -> %{push_id: push_id, push_tokens: tokens}
    end
  end

  defp build_options([]), do: %{}
  defp build_options(options) do
    options
    |> Enum.reduce(%{apns: nil, gcm: nil}, fn(option, acc) ->
      case option.push_type do
        "APNS" -> %{acc | apns: option.option |> Poison.decode! }
        "GCM" -> %{acc | gcm: option.optoin |> Poison.decode! }
        _ -> acc
      end
    end)
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
      "update_dt" => Map.get(param, "updateDt"),
      "request_cnt" => Map.get(param, "requestCnt")
    }
  end


  defp via_push_option_models(param) do
    param
    |> Map.get("options", %{})
    |> Map.to_list
    |> Enum.filter_map(fn({push_type, option}) -> map_size(option) > 0 end,
      fn({push_type, option}) ->
        %{"push_id" => Map.get(param, "pushId"),
          "push_type" => push_type |> String.upcase,
          "option" => option |> Poison.encode! }
      end)
  end

  defp timestamp_to_ecto_datetime(nil), do: nil
  defp timestamp_to_ecto_datetime(obj) when is_map(obj) , do: obj
  defp timestamp_to_ecto_datetime(timestamp) when is_integer(timestamp), do: timestamp |> Calendar.DateTime.Parse.js_ms!

  defp ecto_datetime_to_timestamp(nil), do: nil
  defp ecto_datetime_to_timestamp(datetime) do
    datetime
    |> Ecto.DateTime.to_erl
    |> Calendar.DateTime.from_erl!("Etc/UTC")
    |> Calendar.DateTime.Format.js_ms
  end

  def via_push_page_dto(page = %Scrivener.Page{}) do
    %{
      pageSize: page.page_size,
      startPageNo: 1,
      pageNo: page.page_number,
      endPageNo: page.total_pages,
      totalCount: page.total_entries,
      data: Map.get(page, :entries, []) |> Enum.map(&via_push_dto/1)
    }
  end

  def via_push_dto(model = %HApi.Push{}) do
    %{
      "pushId" => model.push_id,
      "serviceId" => model.service_id,
      "extra" => Poison.decode!(model.extra),
      "message" => %{
        "title" => model.title,
        "body" => model.body
      },
      "condition" => Poison.decode!(model.push_condition),
      "updateDt" => model.update_dt |> ecto_datetime_to_timestamp,
      "createDt" => model.create_dt |> ecto_datetime_to_timestamp,
      "pushStatus" => model.push_status,
      "publishStartDt" => model.publish_start_dt |> ecto_datetime_to_timestamp,
      "publishEndDt" => model.publish_end_dt |> ecto_datetime_to_timestamp,
      "publishTime" => model.publish_end_dt |> ecto_datetime_to_timestamp,
      "pushStats" => get_stats_summary(model.push_id)
    }
  end

  def get_stats_summary(push_id) do
    push_id
    |> PushStatsQuery.summary_by_push_id
    |> Enum.reduce(%{"published" => 0, "opened" => 0, "received" => 0}, fn([key|[value]], acc) ->
      case key do
        "PUB" ->
          %{acc | "published" =>  value |> Decimal.to_string |> Integer.parse |> elem(0) }
        "OPN" ->
          %{acc | "opened" => value |> Decimal.to_string |> Integer.parse |> elem(0) }
        "RCV" ->
          %{acc | "received" => value |> Decimal.to_string |> Integer.parse |> elem(0) }
        _ ->
      end
    end)
  end

end
