defmodule NflRushing.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :player_name, :string
      add :team_name, :string
      add :player_position, :string
      add :rushing_attempts_per_game_avg, :float
      add :rushing_attempts, :integer
      add :total_rushing_yards, :integer
      add :rushing_avg_yards_per_attempt, :float
      add :rushing_yards_per_game, :float
      add :total_rushing_touchdowns, :integer
      add :longest_rush, :string
      add :rushing_first_downs, :integer
      add :rushing_first_down_percentage, :float
      add :rushing_twenty_plus_yards_each, :integer
      add :rushing_forty_plus_yards_each, :integer
      add :rushing_fumbles, :integer

      timestamps()
    end
  end
end
