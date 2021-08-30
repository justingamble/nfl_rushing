defmodule NflRushing.PlayerLoadTest do
  use ExUnit.Case, async: true
  # includes Support.AssertionHelpers, for the 'assert_values_for' function
  use NflRushingWeb.ConnCase

  alias NflRushing.PlayerStats.PlayerStruct

  setup_all do
    all_fields = PlayerStruct.__struct__() |> Map.keys()
    player_struct_fields = all_fields -- [:__struct__]
    %{player_struct_fields: player_struct_fields}
  end

  describe "parse_json_file_into_struct/1" do
    setup do
      alias NflRushing.PlayerStats.PlayerLoad

      player_structs =
        PlayerLoad.parse_json_file_into_a_list_of_structs(
          "test/nfl_rushing/fake_player_data.json"
        )

      %{player_structs: player_structs}
    end

    test "success: accepts a valid file, returns a list of player structs", %{
      player_structs: player_structs
    } do
      for player <- player_structs do
        assert match?(%PlayerStruct{}, player)
      end
    end

    test "success: all fields of a sample player record are converted to a PlayerStruct", %{
      player_structs: player_structs,
      player_struct_fields: player_struct_fields
    } do
      # This test this verifies: a) none of the fields are nil, and b) all the fields are mapped correctly.

      # Expected
      expected_player = %PlayerStruct{
        player_name: "Player 1, all different integers (not floats, not string integers)",
        team_name: "ABC",
        player_position: "DE",
        rushing_attempts_per_game_avg: 1,
        rushing_attempts: 2,
        total_rushing_yards: 3,
        rushing_avg_yards_per_attempt: 4,
        rushing_yards_per_game: 5,
        total_rushing_touchdowns: 6,
        longest_rush: 7,
        rushing_first_downs: 8,
        rushing_first_down_percentage: 9,
        rushing_twenty_plus_yards_each: 10,
        rushing_forty_plus_yards_each: 11,
        rushing_fumbles: 12
      }

      # Actual
      [actual_player | _rest] = player_structs

      # Test
      assert_values_for(
        expected: expected_player,
        actual: actual_player,
        fields: player_struct_fields
      )
    end
  end

  describe "clean_functions" do
    setup do
      alias NflRushing.PlayerStats.PlayerLoad

      # Expected values
      expected_player1 = %PlayerStruct{
        player_name: "Player 1, all different integers (not floats, not string integers)",
        team_name: "ABC",
        player_position: "DE",
        rushing_attempts_per_game_avg: 1.0,
        rushing_attempts: 2,
        total_rushing_yards: 3,
        rushing_avg_yards_per_attempt: 4.0,
        rushing_yards_per_game: 5.0,
        total_rushing_touchdowns: 6,
        longest_rush: "7",
        rushing_first_downs: 8,
        rushing_first_down_percentage: 9.0,
        rushing_twenty_plus_yards_each: 10,
        rushing_forty_plus_yards_each: 11,
        rushing_fumbles: 12
      }

      expected_player2 = %PlayerStruct{
        player_name: "Player 2, all double digits, with floats/strings where possible",
        team_name: "DEF",
        player_position: "GH",
        rushing_attempts_per_game_avg: 11.1,
        rushing_attempts: 12,
        total_rushing_yards: 13,
        rushing_avg_yards_per_attempt: 14.4,
        rushing_yards_per_game: 15.5,
        total_rushing_touchdowns: 16,
        longest_rush: "17",
        rushing_first_downs: 18,
        rushing_first_down_percentage: 19.9,
        rushing_twenty_plus_yards_each: 20,
        rushing_forty_plus_yards_each: 21,
        rushing_fumbles: 22
      }

      expected_player3 = %PlayerStruct{
        player_name: "Player 3, oddballs. Lng has 'T'. Yds has comma. Many 0 values.",
        team_name: "BAL",
        player_position: "WR",
        rushing_attempts_per_game_avg: 0.0,
        rushing_attempts: 1,
        total_rushing_yards: 2099,
        rushing_avg_yards_per_attempt: 0.0,
        rushing_yards_per_game: 0.0,
        total_rushing_touchdowns: 0,
        longest_rush: "2T",
        rushing_first_downs: 0,
        rushing_first_down_percentage: 0.0,
        rushing_twenty_plus_yards_each: 0,
        rushing_forty_plus_yards_each: 0,
        rushing_fumbles: 0
      }

      expected_player4 = %PlayerStruct{
        player_name: "Player 4, negative numbers.",
        team_name: "BAL",
        player_position: "WR",
        rushing_attempts_per_game_avg: -1.2,
        rushing_attempts: -3,
        total_rushing_yards: -4879,
        rushing_avg_yards_per_attempt: -5.0,
        rushing_yards_per_game: -6.7,
        total_rushing_touchdowns: -8,
        longest_rush: "92T",
        rushing_first_downs: -9,
        rushing_first_down_percentage: -98.2,
        rushing_twenty_plus_yards_each: -11,
        rushing_forty_plus_yards_each: -12,
        rushing_fumbles: -15
      }

      player_structs =
        PlayerLoad.get_clean_player_stats_in_a_list_of_structs(
          "test/nfl_rushing/fake_player_data.json"
        )

      [actual_player1, actual_player2, actual_player3, actual_player4] = player_structs

      %{
        actual_player1: actual_player1,
        actual_player2: actual_player2,
        actual_player3: actual_player3,
        actual_player4: actual_player4,
        expected_player1: expected_player1,
        expected_player2: expected_player2,
        expected_player3: expected_player3,
        expected_player4: expected_player4
      }
    end

    test "success: player 1 data is cleaned up correctly", %{
      actual_player1: actual,
      expected_player1: expected,
      player_struct_fields: player_struct_fields
    } do
      assert_values_for(
        expected: expected,
        actual: actual,
        fields: player_struct_fields
      )
    end

    test "success: player 2 data is cleaned up correctly", %{
      actual_player2: actual,
      expected_player2: expected,
      player_struct_fields: player_struct_fields
    } do
      assert_values_for(
        expected: expected,
        actual: actual,
        fields: player_struct_fields
      )
    end

    test "success: player 3 data is cleaned up correctly", %{
      actual_player3: actual,
      expected_player3: expected,
      player_struct_fields: player_struct_fields
    } do
      assert_values_for(
        expected: expected,
        actual: actual,
        fields: player_struct_fields
      )
    end

    test "success: player 4 data is cleaned up correctly", %{
      actual_player4: actual,
      expected_player4: expected,
      player_struct_fields: player_struct_fields
    } do
      assert_values_for(
        expected: expected,
        actual: actual,
        fields: player_struct_fields
      )
    end
  end
end
