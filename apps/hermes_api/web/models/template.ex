defmodule HApi.Template do
  use HApi.Web, :model

  @primary_key {:template_seq, :integer, []}
  @derive {Phoenix.Param, key: :template_seq}
  schema "template" do
    field :service_id, :string
    field :title, :string
    field :html, :string
    field :create_user, :integer, default: 1
    field :update_user, :integer, default: 1
    field :create_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :update_dt, Ecto.DateTime, default: Ecto.DateTime.utc
  end

  @required_fields ~w(service_id html title)
  @optional_fields ~w(create_user create_dt update_user update_dt)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
