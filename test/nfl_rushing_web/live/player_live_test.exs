defmodule NflRushingWeb.PlayerLiveTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest

  test "/ redirects to /players", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/players"}}} = live(conn, "/")
  end

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/players")

    assert disconnected_html =~ "NFL Rushing Statistics"
    refute render(page_live) =~ "NFL Rushing Statistics"  # in root.html.leex template; not part of liveview output

    assert disconnected_html =~ "Filter players"
    assert render(page_live) =~ "Filter players"
  end

  test "with no filtering, 326 players are queried", %{conn: conn} do
    {:ok, view, html} = live(conn, "/players")

    result = view
             |> element("#playerfilter")
             |> render_submit(%{player_name: ""})

   assert result =~ "326"
#   assert true == result
#    assert view
#           |> element("form #player-filter")
#           |> render_click() =~ "326"

#    assert render(page_live) =~ "326"
  end

##  test "by default 5 players are listed", %{conn: conn} do
##    {:ok, page_live, disconnected_html} = live(conn, "/players")
##
##    rendered = render(page_live)
##    assert rendered=~ "Aaron Ripkowski"
###2	Aaron Rodgers	GB	QB	4.2	67	369	5.5	23.1	4	23	25	37.3	3	0	3
###3	Adam Humphries	TB	WR	0.3	5	18	3.6	1.2	0	8	0	0.0	0	0	0
###4	Adam Thielen	MIN	WR	0.1	2	15	7.5	0.9	0	11	1	50.0	0	0	0
###5	Adrian Peterson
###6	Akeem Hunt
##  end

#    IO.puts("Page list is.... [[#{inspect render(page_live), infinite: true}]]")
#    IO.puts("Disconnected_html is.... [[#{inspect disconnected_html}]]")

end
