defmodule HApi.TokenChecker do
  import Plug.Conn

  alias HApi.TokenChecker.Util
  alias HApi.Service.Query, as: ServiceQuery

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    case check_token(conn) do
      {:ok, service} -> assign(conn, :service, service)
      {:error, message} -> send_resp(conn, 401, Poison.encode!(%{error: message})) |> halt
    end
  end

  def check_token(conn) do
     case Util.get_rest_token_by_conn(conn) do
       [token] ->
         case ServiceQuery.select_one_by_rest_token(token) do
           nil -> {:error, "Invalid token"}
           service -> {:ok, service}
         end
       [] -> {:error, "Missing token"}
     end
  end

end


defmodule HApi.TokenChecker.Util do
  import Plug.Conn, only: [get_req_header: 2]

  @rest_header_name "notification-rest-token"

  def get_rest_token_by_conn(conn) do
    get_req_header(conn, @rest_header_name)
  end
end
