defmodule HApi.Repo.Migrations.CreateUserService do
  use Ecto.Migration

  def change do
    create table(:user_service) do

      timestamps
    end

  end
end
