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
    all_columns = get_ordered_list_of_long_headers()

    player
    |> cast(attrs, all_columns)
    |> validate_required(all_columns)
    |> unique_constraint(:player_name)
    |> validate_length(:player_name, min: 2, max: 32)
    |> validate_length(:team_name, min: 2, max: 3)
    |> validate_length(:player_position, min: 1, max: 3)
    |> validate_number(:rushing_attempts, greater_than_or_equal_to: 0)
    |> validate_number(:rushing_avg_yards_per_attempt, less_than_or_equal_to: 100)
    |> validate_format(:longest_rush, ~r/^-?[[:digit:]]+T?$/)
    |> validate_number(:rushing_first_down_percentage, greater_than_or_equal_to: 0)
    |> validate_number(:rushing_first_down_percentage, less_than_or_equal_to: 100)
    |> validate_number(:rushing_fumbles, greater_than_or_equal_to: 0)
  end

  # columns_keyword_list: map field_names to their display text
  @columns_keyword_list [
    player_name: "Player",
    team_name: "Team",
    player_position: "Pos",
    rushing_attempts_per_game_avg: "Att/G",
    rushing_attempts: "Att",
    total_rushing_yards: "Yds",
    rushing_avg_yards_per_attempt: "Avg",
    rushing_yards_per_game: "Yds/G",
    total_rushing_touchdowns: "TD",
    longest_rush: "Lng",
    rushing_first_downs: "1st",
    rushing_first_down_percentage: "1st%",
    rushing_twenty_plus_yards_each: "20+",
    rushing_forty_plus_yards_each: "40+",
    rushing_fumbles: "FUM"
  ]

  @long_to_short_keys Map.new(@columns_keyword_list)

  def get_ordered_list_of_long_headers() do
    for {key, _value} <- @columns_keyword_list, do: key
  end

  def get_ordered_list_of_short_headers() do
    long_headers = get_ordered_list_of_long_headers()

    for elem <- long_headers, into: [] do
      Map.fetch!(@long_to_short_keys, elem)
    end
  end

  def convert_map_keys_to_short_versions(player_map) when is_map(player_map) do
    for {key, value} <- player_map, into: %{} do
      {Map.fetch!(@long_to_short_keys, key), value}
    end
  end
end
