defmodule HApi.Repo.Migrations.CreatePush do
  use Ecto.Migration

  def change do
    create table(:push) do

      timestamps
    end

  end
end
