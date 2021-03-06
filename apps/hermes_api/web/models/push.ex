defmodule HApi.Push do
  use HApi.Web, :model

  @primary_key {:push_id, :string, []}
  @derive {Phoenix.Param, key: :push_id}
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

  @required_fields ~w(push_id body title push_condition extra service_id push_status request_cnt)
  @optional_fields ~w(create_user update_user publish_dt create_dt update_dt)


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

defmodule HApi.Push.Query do
  import Ecto.Query
  alias HApi.Repo
  alias Code.PushStatus

  def insert_model(model) do
    HApi.Push.changeset(%HApi.Push{}, model)
    |> insert
  end
  def insert(changeset) do
    case Repo.insert(changeset) do
      {:ok, push} -> push
      {:error, changeset} -> IO.puts "error : #{inspect changeset}"
    end
  end

  def update(changeset) do
    Repo.update(changeset)
  end

  def select(query, pagination \\ %{} ) do
    from(p in HApi.Push, where: ^query, order_by: [desc: p.create_dt])
    |> Repo.paginate(page: Map.get(pagination, "pageNum", 1), page_size: Map.get(pagination, "pageSize", 10))
  end

  def select_one(query) do
    from(p in HApi.Push, where: ^query)
    |> Repo.one
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
