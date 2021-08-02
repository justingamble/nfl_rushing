defmodule NflRushingWeb.PageController do
  use NflRushingWeb, :controller

  def index(conn, _params) do
    conn |> redirect(to: "/players") |> halt()
  end
end
