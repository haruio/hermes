defmodule HApi.TemplateTest do
  use HApi.ModelCase

  alias HApi.Template

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Template.changeset(%Template{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Template.changeset(%Template{}, @invalid_attrs)
    refute changeset.valid?
  end
end
