defmodule RepoTest do
  use ExUnit.Case, async: true

  alias HScheduler.Model.Push.Query, as: PushQuery

  test "select pagination" do
    assert %Scrivener.Page{
      entries: _entries,
      page_number: _page_number,
      total_pages: _total_pages,
     } = PushQuery.select_by_push_status("RVED")
  end
end
