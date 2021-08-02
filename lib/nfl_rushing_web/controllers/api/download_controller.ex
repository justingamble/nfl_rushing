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

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{@filename}\"")
    |> send_resp(:ok, csv_string)
    #    send_download(conn, {:file, path})
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
