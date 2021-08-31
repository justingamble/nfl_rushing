defmodule NflRushing.PlayerStats.PlayerLoad do
  @moduledoc """
    Contains testable helper functions for pre-processing Player data.
    This module does not deal with Ecto.

    The priv/repo/seeds.exs makes use of these functions, and also loads
    the resulting data into Ecto.
  """

  alias NflRushing.PlayerStats
  alias NflRushing.PlayerStats.PlayerStruct

  import PlayerStats.ConversionHelpers, only: [int_to_str: 1, str_to_int: 1, int_to_float: 1]
  import PlayerStruct

  def get_clean_player_stats_in_a_list_of_structs(filename) when is_binary(filename) do
    parse_json_file_into_a_list_of_structs(filename)
    |> clean_rushing_attempts_per_game_avg
    |> clean_total_rushing_yards
    |> clean_rushing_avg_yards_per_attempt
    |> clean_rushing_yards_per_game
    |> clean_rushing_first_down_percentage
    |> clean_longest_rush
  end

  def parse_json_file_into_a_list_of_structs(filename) when is_binary(filename) do
    {:ok, decoded} =
      File.read!(filename)
      |> String.split("\n", trim: true)
      |> JSON.decode()

    Enum.map(decoded, fn player ->
      %PlayerStruct{
        player_name: player["Player"],
        team_name: player["Team"],
        player_position: player["Pos"],
        rushing_attempts_per_game_avg: player["Att/G"],
        rushing_attempts: player["Att"],
        total_rushing_yards: player["Yds"],
        rushing_avg_yards_per_attempt: player["Avg"],
        rushing_yards_per_game: player["Yds/G"],
        total_rushing_touchdowns: player["TD"],
        longest_rush: player["Lng"],
        rushing_first_downs: player["1st"],
        rushing_first_down_percentage: player["1st%"],
        rushing_twenty_plus_yards_each: player["20+"],
        rushing_forty_plus_yards_each: player["40+"],
        rushing_fumbles: player["FUM"]
      }
    end)
  end

  # Att/G
  # Some rows are integers, some are floats.  Convert all to floats.
  def clean_rushing_attempts_per_game_avg(player_list) do
    Enum.map(player_list, fn player ->
      float_value = int_to_float(player.rushing_attempts_per_game_avg)
      %PlayerStruct{player | rushing_attempts_per_game_avg: float_value}
    end)
  end

  # Yds
  # Some rows are integers, some are strings (either: "839" or "1,043").  Convert all to integers.
  def clean_total_rushing_yards(player_list) do
    Enum.map(player_list, fn player ->
      int_value = str_to_int(player.total_rushing_yards)
      %PlayerStruct{player | total_rushing_yards: int_value}
    end)
  end

  # Avg
  # Some rows are integers, some are floats, some are negative.  Convert all to floats.
  def clean_rushing_avg_yards_per_attempt(player_list) do
    Enum.map(player_list, fn player ->
      float_value = int_to_float(player.rushing_avg_yards_per_attempt)
      %PlayerStruct{player | rushing_avg_yards_per_attempt: float_value}
    end)
  end

  # Yds/G
  # Some rows are integers, some are floats, some are zero, some are negative.  Convert all to floats.
  def clean_rushing_yards_per_game(player_list) do
    Enum.map(player_list, fn player ->
      float_value = int_to_float(player.rushing_yards_per_game)
      %PlayerStruct{player | rushing_yards_per_game: float_value}
    end)
  end

  # Lng
  # Some rows are strings of integers (maybe with "T"), some are integers.  Convert all to string.
  def clean_longest_rush(player_list) do
    Enum.map(player_list, fn player ->
      str_value = int_to_str(player.longest_rush)
      %PlayerStruct{player | longest_rush: str_value}
    end)
  end

  # 1st%
  # Some rows are integers, some are floats, some are zero.  Convert all to floats.
  def clean_rushing_first_down_percentage(player_list) do
    Enum.map(player_list, fn player ->
      float_value = int_to_float(player.rushing_first_down_percentage)
      %PlayerStruct{player | rushing_first_down_percentage: float_value}
    end)
  end

end
