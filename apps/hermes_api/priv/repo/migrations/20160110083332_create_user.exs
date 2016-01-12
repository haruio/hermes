defmodule HApi.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do

      timestamps
    end

  end
end
