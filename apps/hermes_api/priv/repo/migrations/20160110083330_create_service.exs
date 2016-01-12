defmodule HApi.Repo.Migrations.CreateService do
  use Ecto.Migration

  def change do
    create table(:service) do

      timestamps
    end

  end
end
