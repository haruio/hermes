defmodule HApi.Repo.Migrations.CreatePushOption do
  use Ecto.Migration

  def change do
    create table(:push_option) do

      timestamps
    end

  end
end
