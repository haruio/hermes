defmodule HActivity.PushStats do
  use HActivity.Web, :model

  schema "push_stats" do
    field :push_id, :string
    field :stats_start_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :stats_end_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :ststs_cd, :string
    field :stats_cnt, :integer
  end

  @required_fields ~w(push_id ststs_cd stats_cnt)
  @optional_fields ~w(stats_start_dt stats_end_dt)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def cd_published, do: @stats_cd_published
  def cd_opened, do: @stats_cd_opened
  def cd_reeived, do: @stats_cd_received

  defmodule Query do
    import Ecto.Query
    alias HActivity.PushStats
    alias HActivity.Repo

    def insert(model) do
      PushStats.changeset(%PushStats{}, model)
      |> Repo.insert
    end
  end
end
