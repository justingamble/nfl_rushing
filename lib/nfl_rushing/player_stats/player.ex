defmodule NflRushing.PlayerStats.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :player_name, :string
    field :team_name, :string
    field :player_position, :string
    field :rushing_attempts_per_game_avg, :float
    field :rushing_attempts, :integer
    field :total_rushing_yards, :integer
    field :rushing_avg_yards_per_attempt, :float
    field :rushing_yards_per_game, :float
    field :total_rushing_touchdowns, :integer
    field :longest_rush, :string
    field :rushing_first_downs, :integer
    field :rushing_first_down_percentage, :float
    field :rushing_twenty_plus_yards_each, :integer
    field :rushing_forty_plus_yards_each, :integer
    field :rushing_fumbles, :integer
    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    all_columns = [
      :player_name,
      :team_name,
      :player_position,
      :rushing_attempts_per_game_avg,
      :rushing_attempts,
      :total_rushing_yards,
      :rushing_avg_yards_per_attempt,
      :rushing_yards_per_game,
      :total_rushing_touchdowns,
      :longest_rush,
      :rushing_first_downs,
      :rushing_first_down_percentage,
      :rushing_twenty_plus_yards_each,
      :rushing_forty_plus_yards_each,
      :rushing_fumbles
    ]

    player
    |> cast(attrs, all_columns)
    |> validate_required(all_columns)
    |> unique_constraint(:player_name)
    |> validate_length(:player_name, min: 2, max: 32)
    |> validate_length(:team_name, min: 2, max: 3)
    |> validate_length(:player_position, min: 1, max: 3)
    |> validate_number(:rushing_attempts, greater_than_or_equal_to: 0)
    |> validate_format(:longest_rush, ~r/^-?[[:digit:]]+T?$/)
    |> validate_number(:rushing_first_down_percentage, greater_than_or_equal_to: 0)
    |> validate_number(:rushing_first_down_percentage, less_than_or_equal_to: 100)
    |> validate_number(:rushing_fumbles, greater_than_or_equal_to: 0)
  end
end
