defmodule HApi.ErrorView do
  use HApi.Web, :view

  def render(<<status::binary-3>> <> ".json", assigns) do
    assigns
    |> Map.take([:message, :errors])
    |> Map.put(:status, String.to_integer(status))
    |> Map.put_new(:message, message(status))
  end

  def render(_, _assigns) do
    %{errors: %{message: "Server Error"}}
  end

  defp message("400"), do: "Bad request"
  defp message("404"), do: "Page not found"
  defp message("408"), do: "Request timeout"
  defp message("413"), do: "Payload too large"
  defp message("415"), do: "Unsupported media type"
  defp message("422"), do: "Validation error(s)"
  defp message("500"), do: "Internal server error"
  defp message(_),     do: nil
end
