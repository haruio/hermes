defmodule HApi.PushStatsControllerTest do
  use HApi.ConnCase

  alias HApi.PushStats
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, push_stats_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    push_stats = Repo.insert! %PushStats{}
    conn = get conn, push_stats_path(conn, :show, push_stats)
    assert json_response(conn, 200)["data"] == %{"id" => push_stats.id}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, push_stats_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, push_stats_path(conn, :create), push_stats: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(PushStats, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, push_stats_path(conn, :create), push_stats: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    push_stats = Repo.insert! %PushStats{}
    conn = put conn, push_stats_path(conn, :update, push_stats), push_stats: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(PushStats, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    push_stats = Repo.insert! %PushStats{}
    conn = put conn, push_stats_path(conn, :update, push_stats), push_stats: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    push_stats = Repo.insert! %PushStats{}
    conn = delete conn, push_stats_path(conn, :delete, push_stats)
    assert response(conn, 204)
    refute Repo.get(PushStats, push_stats.id)
  end
end
