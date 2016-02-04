defmodule HScheduler.Model.Push do
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
    field :create_user, :integer
    field :update_user, :integer
    field :create_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :update_dt, Ecto.DateTime, default: Ecto.DateTime.utc
  end

  @required_fields ~w(push_id body title push_condition extra service_id push_status )
  @optional_fields ~w(create_user update_user publish_dt create_dt update_dt publish_start_dt publish_end_dt)


  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  defmodule Query do
    alias HScheduler.Repo
    alias HScheduler.Model.Push

    @default_page_size 1000
    @default_page 1

    ## Public API
    def select_by_push_status(status, pagination \\ [page: @default_page, page_size: @default_page_size]) do
      status
      |> by_push_status
      |> Repo.paginate(pagination)
    end

    def select_by_push_status_and_publish_dt(status, publish_dt, pagination \\ [page: @default_page, page_size: @default_page_size]) do
      {status, publish_dt}
      |> by_push_status_publish_dt
      |> Repo.paginate(pagination)
    end

    def update(push_id, params) when is_binary(push_id) do
      push_id
      |> by_push_id
      |> Repo.one
      |> update(params)
    end

    def update(model, params) when is_map(model) do
      Push.changeset(model, params)
      |> update
    end

    def update(changeset) do
      changeset
      |> Repo.update
    end

    ## Private API
    defp by_push_id(push_id) do
      from p in Push,
      where: p.push_id == ^push_id
    end

    defp by_push_status(status) do
      from p in Push,
      where: p.push_status == ^status
    end

    defp by_push_status_publish_dt({status, publish_dt}) do
      from p in Push,
      where: p.push_status == ^status and p.publish_dt <= ^publish_dt
    end
  end
end
