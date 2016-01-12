defmodule HApi.UserServiceTest do
  use HApi.ModelCase

  alias HApi.UserService

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserService.changeset(%UserService{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserService.changeset(%UserService{}, @invalid_attrs)
    refute changeset.valid?
  end
end
