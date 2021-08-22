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

# -------------------------------------------------------------------
# This file will load the input file into a list of Structs, and then
# attempt to load the data into the database.  A number of schema
# validations are applied to help ensure database integrity.
# If there are any loading errors, a sumary of the load errors is
# printed at the end of the console output.

alias NflRushing.PlayerStats

import PlayerStats.PlayerLoad,
  only: [get_clean_player_stats_in_a_list_of_structs: 1]

import Ecto.Changeset, only: [get_change: 2, traverse_errors: 2]

players = get_clean_player_stats_in_a_list_of_structs("priv/repo/rushing.json")

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
    {status, changeset} =
      player
      |> Map.from_struct
      |> PlayerStats.create_player

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
    "***** ERROR LOADING DATA *****\n" <>
      "#{map_size(error_map)} errors found loading the database." <>
      "  Failed to load the following player records:"
  )

  error_map
  |> Enum.with_index()
  |> Enum.each(fn {{key, value}, i} ->
    IO.puts("    #{i}. Player=#{inspect(key)}.  Error message: #{inspect(value)}")
  end)
else
  IO.puts("Data successfully loaded!\n")
end
