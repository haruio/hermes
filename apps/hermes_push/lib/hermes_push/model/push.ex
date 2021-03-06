defmodule HPush.Model.Push do
  use Ecto.Model

  @primary_key {:push_id, :string, []}
  schema "push" do
    field :service_id, :string
    field :push_condition, :string
    field :push_status, :string
    field :publish_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :publish_start_dt, Ecto.DateTime
    field :publish_end_dt, Ecto.DateTime
    field :body, :string
    field :title, :string
    field :extra, :string
    field :request_cnt, :integer
    field :create_user, :integer
    field :update_user, :integer
    field :create_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :update_dt, Ecto.DateTime, default: Ecto.DateTime.utc
  end

  @required_fields ~w(push_id)
  @optional_fields ~w(create_user update_user publish_dt create_dt update_dt body title push_condition extra service_id push_status request_cnt publish_start_dt publish_end_dt)


  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule HPush.Model.Push.Query do
  import Ecto.Query
  alias HPush.Model.Push
  alias HPush.Repo

  def update(changeset) do
    Repo.update(changeset)
  end

  def update(query, set) do
    from(p in HPush.Model.Push, where: ^query)
    |> Repo.update_all(set: set)
  end

  def select_one_by_push_id(nil), do: nil
  def select_one_by_push_id([push_id]), do: select_one_by_push_id(push_id)
  def select_one_by_push_id(push_id) do
    push_id
    |> by_push_id
    |> Repo.one
  end

  def by_push_id(push_id) do
    from p in HApi.Push,
    where: p.push_id == ^push_id
  end
end
