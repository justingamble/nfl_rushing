# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     NflRushing.Repo.insert!(%NflRushing.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
# -------------
# This file will load the input file into a list of Structs, and then
# attempt to load the data into the database.  A number of
# schema validations are applied to help ensure database integrity.
# If there are any loading errors, a sumary of the load errors is printed
# at the end of the console output.

alias NflRushing.PlayerStats
import PlayerStats.PlayerStruct

import PlayerStats.PlayerLoad,
  only: [get_clean_player_stats_in_a_list_of_structs: 1]

# import PlayerStats.PlayerLoad
import Ecto.Changeset, only: [get_change: 2, traverse_errors: 2]

players = get_clean_player_stats_in_a_list_of_structs("priv/repo/rushing.json")

IO.puts("The structured data.... #{inspect(players, pretty: true)}")

# players = [
#  %{
#    player_name: "Shawn Hill",
#    team_name: "MIN",
#    player_position: "QC",
#    total_rushing_yards: 23,
#    rushing_avg_yards_per_attempt: 2.3,
#    rushing_yards_per_game: 7,
#    total_rushing_touchdowns: 9,
#    rushing_attempts: 20,
#    rushing_attempts_per_game_avg: 2.3,
#    longest_rush: "82",
#    rushing_first_downs: 98,
#    rushing_first_down_percentage: 82.7,
#    rushing_twenty_plus_yards_each: 20,
#    rushing_forty_plus_yards_each: 40,
#    rushing_fumbles: 0
#  },
# ]

# TODO JUSTIN: can you use the 'errors_on' function, defined in test/support/data_case.ex ?
# (Hmm, importing NflRushing.DataCase does not work)
get_player_name_and_error_string_for_changeset = fn changeset ->
  player_name = get_change(changeset, :player_name)

  error_string =
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)

  {player_name, error_string}
end

error_map =
  Enum.reduce(players, %{}, fn player, acc_map ->
    # TODO: Justin, turn this into a pipeline.
    player_as_map = Map.from_struct(player)
    {status, changeset} = PlayerStats.create_player(player_as_map)

    _acc_map =
      case status do
        :error ->
          {player_name, error_string} = get_player_name_and_error_string_for_changeset.(changeset)
          Map.put(acc_map, player_name, error_string)

        _ ->
          acc_map
      end
  end)

:timer.sleep(2_000)

if map_size(error_map) > 0 do
  IO.puts(
    "***** ERRORS LOADING DATA *****\n" <>
      "#{map_size(error_map)} errors found loading the database." <>
      "  Failed to load the following player records:"
  )

  error_map
  |> Enum.with_index()
  |> Enum.each(fn {{key, value}, i} ->
    IO.puts("    #{i}. Player=#{inspect(key)}.  Error message: #{inspect(value)}")
  end)
else
  IO.puts("Data successfully loaded!  No loading errors.\n")
end

IO.puts("Done this function!")
