defmodule DTOUtil do

  def to_dto(%Scrivener.Page{} = page) do
    %{
      pageSize: page.page_size,
      startPageNo: 1,
      pageNo: page.page_number,
      endPageNo: page.total_pages,
      totalCount: page.total_entries,
      data: Map.get(page, :entries, []) |> Enum.map(&to_camel_case/1)
    }
  end

  def to_dto(model) do
    model
    |> to_camel_case
  end

  def to_camel_case(struct) do
    struct
    |> put_or_not(:create_dt, Map.get(struct, :create_dt) |> ecto_datetime_to_timestamp)
    |> put_or_not(:update_dt, Map.get(struct, :update_dt) |> ecto_datetime_to_timestamp)
    |> Map.delete(:__meta__)
    |> Map.delete(:__struct__)
    |> ProperCase.to_camel_case
  end

  defp put_or_not(map, _name, nil), do: map
  defp put_or_not(map, name, value) do
    map
    |> Map.put(name, value)
  end

  defp ecto_datetime_to_timestamp(nil), do: nil
  defp ecto_datetime_to_timestamp(datetime) do
    datetime
    |> Ecto.DateTime.to_erl
    |> Calendar.DateTime.from_erl!("Etc/UTC")
    |> Calendar.DateTime.Format.js_ms
  end
end
