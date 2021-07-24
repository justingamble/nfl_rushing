defmodule NflRushing.PlayerStats.PlayerStruct do
  defstruct player_name: "",
            team_name: "",
            player_position: "",
            rushing_attempts_per_game_avg: 0.0,
            rushing_attempts: 0,
            total_rushing_yards: 0,
            rushing_avg_yards_per_attempt: 0.0,
            rushing_yards_per_game: 0,
            total_rushing_touchdowns: 0,
            longest_rush: 0,
            rushing_first_downs: 0,
            rushing_first_down_percentage: 0.0,
            rushing_twenty_plus_yards_each: 0,
            rushing_forty_plus_yards_each: 0,
            rushing_fumbles: 0
end
