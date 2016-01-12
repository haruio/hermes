defmodule HApi.ServiceOptionTest do
  use HApi.ModelCase

  alias HApi.ServiceOption

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ServiceOption.changeset(%ServiceOption{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ServiceOption.changeset(%ServiceOption{}, @invalid_attrs)
    refute changeset.valid?
  end
end
