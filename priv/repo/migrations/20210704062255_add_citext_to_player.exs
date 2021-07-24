defmodule NflRushing.Repo.Migrations.AddCitextToPlayer do
  use Ecto.Migration

  def up do
    alter table(:players) do
      modify :player_name, :citext, null: false
    end
  end

  def down do
    alter table(:players) do
      modify :player_name, :string, null: false
    end
  end
end
