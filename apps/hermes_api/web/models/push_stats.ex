defmodule HApi.PushStats do
  use HApi.Web, :model

  schema "push_stats" do
    field :push_id, :string
    field :stats_start_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :stats_end_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :ststs_cd, :string
    field :stats_cnt, :integer
  end

  @required_fields ~w(push_id ststs_cd)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  defmodule Query do
    import Ecto.Query
    alias HApi.PushStats
    alias HApi.Repo

    def summary_by_push_id(%{"push_id" => push_id}), do: summary_by_push_id(push_id)
    def summary_by_push_id(push_id) do
      from(stats in PushStats,
           where: stats.push_id == ^push_id,
           group_by: stats.ststs_cd,
           select: [stats.ststs_cd, sum(stats.stats_cnt)])
      |> Repo.all
    end
  end

end
