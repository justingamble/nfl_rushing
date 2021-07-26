defmodule NflRushingWeb.Api.DownloadController do

  use NflRushingWeb, :controller

  alias NflRushing.PlayerStats
#  alias NflRushing.PlayerStats.Player


  def index(conn, %{"sort_by" => sort_by, "player_filter" => player_filter, "return_to" => return_to} = params) do
    IO.puts("*** download controller index executing!")
    IO.puts("My params are #{inspect params}")
    IO.puts(" .... My player filter is #{inspect player_filter}")
    IO.puts(" .... My sort column is #{inspect sort_by}")
    IO.puts(" .... My return to is [#{inspect return_to}]")

    my_players = list_players(player_filter, String.to_atom(sort_by))
    IO.puts("My players are: #{inspect my_players}")

    path = Application.app_dir(:nfl_rushing, "priv/sample_download.csv")
    send_download(conn, {:file, path})

    :timer.sleep(3000)

#    render(conn, "index.json", test: "test123")
#    redirect(conn, to: Routes.page_path(conn, :players))
    redirect(conn, to: return_to)

#    case add_key_value_to_cache(params) do
#      {:ok, key, value} ->
#        conn
#        |> put_status(200)
#        |> render("show.json", key: key, value: value)
#
#      _ ->
#        conn
#        |> put_status(422)
#        |> json(%{"ERROR" => "Unrecognized parameter: #{inspect(params)}"})
#    end
  end

  defp list_players(player_filter, sort_by) do
    PlayerStats.list_players(
      player_name: player_filter,
      sort_by: sort_by
    )
  end
end
