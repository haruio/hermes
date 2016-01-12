defmodule HApi.TemplateControllerTest do
  use HApi.ConnCase

  alias HApi.Template
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, template_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    template = Repo.insert! %Template{}
    conn = get conn, template_path(conn, :show, template)
    assert json_response(conn, 200)["data"] == %{"id" => template.id}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, template_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, template_path(conn, :create), template: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Template, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, template_path(conn, :create), template: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    template = Repo.insert! %Template{}
    conn = put conn, template_path(conn, :update, template), template: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Template, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    template = Repo.insert! %Template{}
    conn = put conn, template_path(conn, :update, template), template: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    template = Repo.insert! %Template{}
    conn = delete conn, template_path(conn, :delete, template)
    assert response(conn, 204)
    refute Repo.get(Template, template.id)
  end
end
