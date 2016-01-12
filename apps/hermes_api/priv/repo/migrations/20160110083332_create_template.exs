defmodule HApi.Repo.Migrations.CreateTemplate do
  use Ecto.Migration

  def change do
    create table(:template) do

      timestamps
    end

  end
end
