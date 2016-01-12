defmodule HApi.Repo.Migrations.CreatePushStats do
  use Ecto.Migration

  def change do
    create table(:push_stats) do

      timestamps
    end

  end
end
