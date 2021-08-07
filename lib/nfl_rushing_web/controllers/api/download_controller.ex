defmodule NflRushingWeb.Api.DownloadController do
  use NflRushingWeb, :controller
  #  alias NflRushing.PlayerStats

  @filename "NflRushing.Player.Download.csv"

  def download(conn, %{"sort_by" => sort_by, "player_filter" => player_filter} = _params) do
    IO.puts("*** download controller index executing!")
    IO.puts(" .... My player filter is #{inspect(player_filter)}")
    IO.puts(" .... My sort column is #{inspect(sort_by)}")

    # path = Application.app_dir(:nfl_rushing, "priv/sample_download.csv")

    #    header_string = PlayerStats.get_stats_headers()
    #    IO.puts(
    #      "\n*********** BEFORE get_list_of_players_as_csv_stream.  stats_headers=#{
    #        inspect(header_string)
    #      } *****\n"
    #    )

    #    body_string =
    #      list_players(player_filter, String.to_atom(sort_by))
    #      |> get_csv_string

    #    csv_string = header_string <> "\n" <> body_string

    #    live_path = Routes.live_path(conn, NflRushingWeb.PlayerLive.Index)

    criteria = [player_name: player_filter, sort_by: String.to_atom(sort_by)]

    # Credit to: https://medium.com/@feymartynov/streaming-csv-report-in-phoenix-4503b065bf4a
    # for the idea to use streaming for the download
    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", ~s[attachment; filename="#{@filename}"])
      |> Plug.Conn.send_chunked(:ok)

    #    player_stream = PlayerStats.get_list_of_players_as_csv_stream(criteria)
    #    IO.puts("\n*********** AFTER get_list_of_players_as_csv_stream *****\n")

    # Why use a callback as 2nd parameter?  To keep a separation of concerns.
    # This function has access to 'conn', while the NflRushing.PlayerStats module does not.
    # The NflRushing.PlayerStats module has access to NflRushing.Repo, while this module does not.
    {:ok, conn} =
      NflRushing.PlayerStats.write_csv_download_file_from_player_query_stream(
        criteria,
        fn stream ->
          stream
          |> Enum.reduce_while(conn, fn data, conn ->
            case chunk(conn, data) do
              {:ok, conn} -> {:cont, conn}
              {:error, :closed} -> {:halt, conn}
            end
          end)
        end
      )

    conn
  end

  # TODO: Do I need this function?  Just call PlayerStats directly?
  #  defp list_players(player_filter, sort_by) when is_atom(sort_by) do
  #    PlayerStats.list_players(
  #      player_name: player_filter,
  #      sort_by: sort_by
  #    )
  #  end

  #  defp get_csv_string(list_of_players) do
  #    list_of_players
  #    |> Enum.map(fn player -> "#{player}\n" end)
  #    |> List.flatten()
  #    |> to_string
  #  end
end
