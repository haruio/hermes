defmodule HScheduler.Job.PublishReservedPush do
  use ExActor.GenServer, export: __MODULE__

  @default_page_size 1000

  alias HScheduler.Model.Push.Query, as: PushQuery
  alias HScheduler.Model.Push
  alias HScheduler.Store.PushTokenStore
  alias HScheduler.Producer.PushProducer

  defstart start_link, do: initial_state(:ok)

  defcall do_job do
    loop
    reply :ok
  end

  def loop do
    %Scrivener.Page{
      entries: entries,
      total_pages: total_pages,
    } = PushQuery.select_by_push_status_and_publish_dt("RVED", Ecto.DateTime.utc ,page_number: 1, page_size: @default_page_size)


    entries
    |> Stream.each(&publish/1)
    |> Stream.run


    if total_pages > 1, do: loop
  end

  defp publish(push) do
    PushProducer.publish(push)
  end
end
