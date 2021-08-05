defmodule NflRushing.PlayerStats.Player do
  use Ecto.Schema
  import Ecto.Changeset

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
    all_columns = for {key, _value} <- @columns_keyword_list, do: key

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

  def get_stats_headers() do
    for {_key, value} <- @columns_keyword_list, do: value
  end

  # Sample format of this structure:
  #
  #     %NflRushing.PlayerStats.Player{
  #      __meta__: #Ecto.Schema.Metadata<:loaded, "players">,
  #      id: 1558,
  #      inserted_at: ~N[2021-07-03 22:03:54],
  #      longest_rush: "0",
  #      player_name: "Joe Kerridge",
  #      player_position: "RB",
  #      rushing_attempts: 1,
  #      rushing_attempts_per_game_avg: 0.1,
  #      rushing_avg_yards_per_attempt: 0.0,
  #      rushing_first_down_percentage: 0.0,
  #      rushing_first_downs: 0,
  #      rushing_forty_plus_yards_each: 0,
  #      rushing_fumbles: 0,
  #      rushing_twenty_plus_yards_each: 0,
  #      rushing_yards_per_game: 0.0,
  #      team_name: "GB",
  #      total_rushing_touchdowns: 0,
  #      total_rushing_yards: 0,
  #      updated_at: ~N[2021-07-03 22:03:54]
  #     }
  #
  # This function is used, for example, when writing out the database data to CSV file.
  defimpl String.Chars, for: __MODULE__ do
    def to_string(player) do
      fields = [
        player.player_name,
        player.team_name,
        player.player_position,
        player.rushing_attempts_per_game_avg,
        player.rushing_attempts,
        player.total_rushing_yards,
        player.rushing_avg_yards_per_attempt,
        player.rushing_yards_per_game,
        player.total_rushing_touchdowns,
        player.longest_rush,
        player.rushing_first_downs,
        player.rushing_first_down_percentage,
        player.rushing_twenty_plus_yards_each,
        player.rushing_forty_plus_yards_each,
        player.rushing_fumbles
      ]

      _string = "" <> Enum.join(fields, ",")
    end
  end
end
