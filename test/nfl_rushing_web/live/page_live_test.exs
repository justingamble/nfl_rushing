defmodule NflRushingWeb.PageLiveTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest

  test "/ redirects to /players", %{conn: conn} do
    {:error, {:redirect, %{to: to_redirect}}} = live(conn, "/")
    assert to_redirect =~ "/players"
  end

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/players")

    assert disconnected_html =~ "NFL Rushing Statistics"
    refute render(page_live) =~ "NFL Rushing Statistics"  # in root.html.leex template; not part of liveview output

    assert disconnected_html =~ "Filter players"
    assert render(page_live) =~ "Filter players"
  end

#    IO.puts("Page list is.... [[#{inspect render(page_live), infinite: true}]]")
#    IO.puts("Disconnected_html is.... [[#{inspect disconnected_html}]]")

end
