defmodule NflRushingWeb.PageController do
  use NflRushingWeb, :controller

  def index(conn, _params) do
    start_path = Routes.live_path(conn, NflRushingWeb.PlayerLive.Index)

    conn
    |> redirect(to: start_path)
    |> halt()
  end
end
