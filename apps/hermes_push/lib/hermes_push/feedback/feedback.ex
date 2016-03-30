defmodule HPush.Feedback do
  use GenServer

  require Logger

  @init_state %{}
  @feedback_config Application.get_env(:hermes_push, __MODULE__)
  @feedback_headers [{"Content-Type", "application/json"}]


  def start_link(args \\[]) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_args) do
    {:ok, @init_state}
  end


  def feedback(pid, {:gcm, message, tokens}) do
    GenServer.cast(pid, {:gcm, message, tokens})
  end

  def feedback(pid, {:apns, message}) do
    GenServer.cast(pid, {:apns, message})
  end


  def handle_cast({:gcm, message, tokens}, state) do
    case Poison.Parser.parse(message.body) do
      {:ok, parsed_body} ->
        parsed_body
        |> get_changed_gcm_tokens(tokens)
        |> send_changed_tokens
      _ ->
        Logger.error "[#{__MODULE__}] GCM_RES Parse Error"
    end

    {:noreply, state}
  end

  def handle_cast({:apns, message}, state) do

    {:noreply, state}
  end

  defp get_changed_gcm_tokens(parsed_body, old_tokens) do
    get_changed_gcm_tokens(parsed_body["results"], old_tokens, [], [])
  end
  defp get_changed_gcm_tokens([], [], deleted_tokens, updated_tokens), do: {deleted_tokens, updated_tokens}
  defp get_changed_gcm_tokens([changed_h | changed_t], [old_h | old_t], deleted_tokens, updated_tokens) do
    case(changed_h) do
      %{"error" => "InvalidRegistration"} ->
        deleted_tokens = deleted_tokens ++ [old_h]
      %{"error" => "NotRegistered"} ->
        deleted_tokens = deleted_tokens ++ [old_h]
      %{"message_id" => _, "registration_id" =>  updated_token} ->
        updated_tokens = updated_tokens ++ [ %{from: old_h, to: updated_token} ]
      _ ->
    end

    get_changed_gcm_tokens(changed_t, old_t, deleted_tokens, updated_tokens)
  end

  defp send_changed_tokens({deleted_tokens, changed_tokens}) do
    send_tokens(:delete, deleted_tokens)
    send_tokens(:update, changed_tokens)
  end


  defp send_tokens(_, []), do: :ok
  defp send_tokens(verb, tokens) when is_atom(verb)  do
    case @feedback_config[verb] do
      nil -> {:error, "Invalid verb"}
      url ->
        Task.async(fn ->
          HTTPoison.post!(@feedback_config[:delete], tokens |> Poison.encode!, @feedback_headers)
        end)
    end
  end
end
