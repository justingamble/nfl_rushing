defmodule NflRushingWeb.Api.DownloadController do
  use NflRushingWeb, :controller
  use Task

  @filename "NflRushing.Player.Download.csv"

  def start_link(arg) do
    Task.start_link(__MODULE__, :download2, [arg])
  end

  def download(conn, %{"sort_by" => sort_by, "player_filter" => player_filter} = _params) do
    IO.puts(
      "===================================================================================="
    )

    IO.puts(
      "Download_controller.ex.... My player filter=#{inspect(player_filter)}, sort column=#{
        inspect(sort_by)
      }"
    )

    criteria = [player_name: player_filter, sort_by: String.to_atom(sort_by)]

    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", ~s[attachment; filename="#{@filename}"])
      |> Plug.Conn.send_chunked(:ok)

    # Why use a callback as 2nd parameter?  To keep a separation of concerns.
    # This function has access to 'conn', while the NflRushing.PlayerStats module does not.
    # The NflRushing.PlayerStats module has access to NflRushing.Repo, while this module does not.
    {:ok, conn} =
      NflRushing.PlayerStats.write_csv_download_file_from_player_query_stream(
        criteria,
        fn stream ->
          stream
          |> Enum.reduce_while(conn, fn data, conn ->
            case Plug.Conn.chunk(conn, data) do
              {:ok, conn} -> {:cont, conn}
              {:error, :closed} -> {:halt, conn}
            end
          end)
        end
      )

    conn
    |> halt
  end
end
