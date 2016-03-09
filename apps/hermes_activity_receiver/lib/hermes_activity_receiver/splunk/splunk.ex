defmodule Splunk do
  use Connection

  @default_timeout 5000

  defmodule State do
    defstruct host: nil, port: nil, opts: [], timeout: nil , socket: nil
  end

  # Public API
  def start_link(nil) do
    IO.puts "Splunk Config Error"
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
        IO.puts "Splunk TCP Connection success: #{inspect socket}"
        {:ok, %Splunk.State{state | socket: socket}}
      {:error, reason} ->
        IO.puts "Splunk TCP Connection error: #{inspect reason}"
        {:backoff, 1000, state}
    end
  end

  def disconnect(info, %Splunk.State{socket: socket} = state) do
    :ok = :gen_tcp.close(socket)
    case info do
      {:close, from} ->
        Connection.reply(from, :ok)
      {:error, :closed} ->
        IO.puts "Splunk TCP Connection closed"
      {:error, reason} ->
        reason = :inet.format_error(reason)
        IO.puts "Splunk TCP error #{inspect reason}"
    end

    {:connect, :reconnect, %Splunk.State{state | socket: nil}}
  end

  def handle_call({:send, data}, _, %Splunk.State{socket: socket} = state) do
    case :gen_tcp.send(socket, data) do
      :ok -> {:reply, :ok, state}
      {:error, _} = error ->
        {:disconnect, error, error, state}
    end
  end
end
