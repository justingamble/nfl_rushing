defmodule NflRushingWeb.PageController do
  use NflRushingWeb, :controller

  def index(conn, _params) do
    live_path = Routes.live_path(conn, NflRushingWeb.PlayerLive.Index)

    conn
    |> redirect(to: live_path)
    |> halt()
  end
end
