defmodule HScheduler.Job.CancelReservedPush do
  use ExActor.GenServer, export: __MODULE__

  @default_page_size 1000

  alias HScheduler.Model.Push.Query, as: PushQuery
  alias HScheduler.Model.Push
  alias HScheduler.Store.PushTokenStore

  defstart start_link, do: initial_state(:ok)

  defcall do_job do
    loop
    reply :ok
  end

  def loop do
    %Scrivener.Page{
      entries: entries,
      total_pages: total_pages,
    } = PushQuery.select_by_push_status("CAING", page_number: 1, page_size: @default_page_size)

    entries
    |> Stream.each(&cancel/1)
    |> Stream.run

    if total_pages > 1, do: loop
  end

  defp cancel(push) do
    ## delete push tokens
    push.push_id
    |> PushTokenStore.delete

    ## update push status
    push
    |> Push.changeset(%{push_status: "CAED", update_dt: Ecto.DateTime.utc})
    |> PushQuery.update
  end
end
