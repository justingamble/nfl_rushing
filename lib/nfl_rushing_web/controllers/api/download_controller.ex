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

    csv_string = header_string <> "\n" <> body_string

#    live_path = Routes.live_path(conn, NflRushingWeb.PlayerLive.Index)

    # Credit to: https://medium.com/@feymartynov/streaming-csv-report-in-phoenix-4503b065bf4a
    # for the idea to use streaming for the download
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s[attachment; filename="#{@filename}"])
    |> send_chunked(:ok)

    PlayerStats.list_players_with_stream fn stream ->
      for result <- stream do
        csv_rows = NimbleCSV.RFC4180.dump_to_iodata(result.rows)
        conn |> chunk(csv_rows)
      end
    end

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
    |> List.flatten
    |> to_string
  end
end
