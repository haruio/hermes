defmodule Splunk do
  use Connection

  require Logger

  @default_timeout 100

  defmodule State do
    defstruct host: nil, port: nil, opts: [], timeout: nil , socket: nil, queue: :queue.new
  end

  # Public API
  def start_link(nil) do
    Logger.error "[#{__MODULE__}] Splunk config error"
  end

  def start_link(host, port, opts, timeout \\ 5000) do
    Connection.start_link(__MODULE__, [host: host, port: port, opts: opts, timeout: timeout])
  end

  def start_link(env) when is_list(env) do
    Connection.start_link(__MODULE__, env)
  end

  def send(conn, data), do: Connection.call(conn, {:send, data})

  def close(conn), do: Connection.call(conn, :close)

  # Callback API
  def init(args) do
    state = %Splunk.State{host: args[:host], port: args[:port], opts: Keyword.get(args, :opts, []), timeout: Keyword.get(args, :timeout, @default_timeout)}
    {:connect, nil, state}
  end

  def connect(_info, state = %Splunk.State{host: host, port: port, opts: opts, timeout: timeout}) do
    case :gen_tcp.connect(host, port, opts) do
      {:ok, socket} ->
        Logger.info "[#{__MODULE__}] Splunk TCP Connection success: #{inspect socket}"
        {:ok, %Splunk.State{state | socket: socket}}
      {:error, reason} ->
        Logger.error "[#{__MODULE__}] TCP Connection Error: #{inspect reason}"
        {:backoff, timeout, state}
    end
  end

  def disconnect(info, %Splunk.State{socket: socket} = state) do
    :ok = :gen_tcp.close(socket)
    case info do
      {:close, from} ->
        Connection.reply(from, :ok)
      {:error, :closed} ->
        Logger.error "[#{__MODULE__}] TCP Connection closed"
      {:error, reason} ->
        reason = :inet.format_error(reason)
        Logger.error "[#{__MODULE__}] TCP Connection Error: #{inspect reason}"
    end

    {:connect, :reconnect, %Splunk.State{state | socket: nil}}
  end

  def handle_call({:send, data}, _, %Splunk.State{socket: socket} = state) do
    case :gen_tcp.send(socket, data) do
      :ok ->
        {:reply, :ok, state}
      {:error, _} = error ->
        Logger.error "[#{__MODULE__}] Send error"
        {:disconnect, error, error, %Splunk.State{state | queue: :queue.in(data, state.queue)}}
    end
  end

  def handle_cast(:flush_queue, %Splunk.State{socket: socket, queue: queue} = state) do
    merge_data = :queue.to_list(queue)
    |> Enum.reduce("", fn(data, acc) -> data <> "\u000A" <> acc end)

    Splunk.send(self, merge_data)

    {:noreply, %Splunk.State{state | queue: :queue.new}}
  end
end
