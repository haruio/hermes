defmodule HApi.Repo.Migrations.CreateServiceOption do
  use Ecto.Migration

  def change do
    create table(:service_option) do

      timestamps
    end

  end
end
