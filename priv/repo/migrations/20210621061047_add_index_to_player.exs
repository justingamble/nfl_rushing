defmodule NflRushing.Repo.Migrations.AddIndexToPlayer do
  use Ecto.Migration

  def change do
    create index(:players, :total_rushing_yards)
    create index(:players, :longest_rush)
    create index(:players, :total_rushing_touchdowns)
    create unique_index(:players, :player_name)
  end
end
