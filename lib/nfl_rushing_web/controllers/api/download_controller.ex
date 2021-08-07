defmodule NflRushingWeb.Api.DownloadController do
  use NflRushingWeb, :controller
  alias NflRushing.PlayerStats

  @filename "Player.Download.csv"

  def download(conn, %{"sort_by" => sort_by, "player_filter" => player_filter} = _params) do
    IO.puts("*** download controller index executing!")
    IO.puts(" .... My player filter is #{inspect(player_filter)}")
    IO.puts(" .... My sort column is #{inspect(sort_by)}")

    # path = Application.app_dir(:nfl_rushing, "priv/sample_download.csv")

    header_string = PlayerStats.get_stats_headers()

    body_string =
      list_players(player_filter, String.to_atom(sort_by))
      |> get_csv_string

    #    csv_string = header_string <> "\n" <> body_string

    #    live_path = Routes.live_path(conn, NflRushingWeb.PlayerLive.Index)

    # Credit to: https://medium.com/@feymartynov/streaming-csv-report-in-phoenix-4503b065bf4a
    # for the idea to use streaming for the download
    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", ~s[attachment; filename="#{@filename}"])
      |> Plug.Conn.send_chunked(:ok)

    criteria = [player_name: player_filter, sort_by: String.to_atom(sort_by)]

    IO.puts(
      "\n*********** BEFORE get_list_of_players_as_csv_stream.  stats_headers=#{
        inspect(header_string)
      } *****\n"
    )

    player_stream = PlayerStats.get_list_of_players_as_csv_stream(criteria)
    IO.puts("\n*********** AFTER get_list_of_players_as_csv_stream *****\n")

    # Ideas:
    # 1. Swap the map_keys with your custom_map_keys
    # 2. Convert map to list, sorter into your preferred order, and convert back to a map
    #        - Use Enum.sort/3
    #        - Have a map function of each column to its numeric position, and the
    #          sort mapper function can then just return which one is lower.
    # 3. Move this logic into player_stats.ex.  But the transaction need conn.  Use callback?
    my_stream =
      player_stream
      |> Stream.map(fn x ->
        IO.puts("================== before from_struct.. #{inspect(x)}\n")
        x
      end)
      |> Stream.map(&Map.from_struct(&1))
      |> Stream.map(fn x ->
        IO.puts("================== after from_struct.. #{inspect(x)}\n")
        x
      end)
      |> Stream.map(&Map.drop(&1, [:__meta__, :id, :inserted_at, :updated_at]))
      |> Stream.map(fn x ->
        IO.puts("================== after dropping extra fields.. #{inspect(x)}\n")
        x
      end)
      |> CSV.Encoding.Encoder.encode(headers: true)
      #      |> CSV.Encoding.Encoder.encode(headers: header_string) <----- TODO: convert my map to one with header_string headers
      |> Stream.map(fn x ->
        IO.puts("================== after CSV.encode  #{inspect(x)}\n")
        x
      end)

    {:ok, conn} =
      NflRushing.Repo.transaction(fn ->
        IO.puts("Transaction, line 1\n")

        my_stream
        |> Enum.reduce_while(conn, fn data, conn ->
          case chunk(conn, data) do
            {:ok, conn} -> {:cont, conn}
            {:error, :closed} -> {:halt, conn}
          end
        end)
      end)

    conn
  end

  # TODO: Do I need this function?  Just call PlayerStats directly?
  defp list_players(player_filter, sort_by) when is_atom(sort_by) do
    PlayerStats.list_players(
      player_name: player_filter,
      sort_by: sort_by
    )
  end

  defp get_csv_string(list_of_players) do
    list_of_players
    |> Enum.map(fn player -> "#{player}\n" end)
    |> List.flatten()
    |> to_string
  end
end
