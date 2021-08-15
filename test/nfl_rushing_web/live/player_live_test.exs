defmodule NflRushingWeb.PlayerLiveTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest

  @default_page_size  5

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

  test "with no players in database, check that the correct form components are shown", %{conn: conn} do
    {:ok, view, html} = live(conn, "/players")

    assert has_element?(view, "#player-filter-form")
    assert has_element?(view, "#number-player-results", "0")

    refute has_element?(view, "#loading-icon", "Loading...")

    refute has_element?(view, "#per-page-dropbox")
    refute has_element?(view, "#pagination-left-arrow")
    refute has_element?(view, "#pagination-number-1")
    refute has_element?(view, "#pagination-number-2")
    refute has_element?(view, "#pagination-right-arrow")

    refute has_element?(view, "#sort-by-dropbox")
    refute has_element?(view, "#download-link")
    refute has_element?(view, "#player-table")
  end

  test "with a single player in database, check that the correct form components are shown", %{conn: conn} do
    player_1 = create_test_player(%{player_name: "Player #1"})

    {:ok, view, html} = live(conn, "/players")

    IO.puts("********* Results: [[#{inspect render(view), infinite: true}]]")

    assert has_element?(view, "#player-filter-form")
    assert has_element?(view, "#number-player-results", "1")

    refute has_element?(view, "#loading-icon", "Loading...")

    # only 1 page of results, so the page-dropbox and pagination links should be hidden
    refute has_element?(view, "#per-page-dropbox")
    refute has_element?(view, "#pagination-left-arrow")
    refute has_element?(view, "#pagination-number-1")
    refute has_element?(view, "#pagination-number-2")
    refute has_element?(view, "#pagination-right-arrow")

    assert has_element?(view, "#sort-by-dropbox")
    assert has_element?(view, "#download-link")
    assert has_element?(view, "#player-table")
  end

  test "with more than 1 page of players in database, check that the correct form components are shown", %{conn: conn} do
    for player_num <- 1..(@default_page_size+1) do
      create_test_player(%{player_name: "Player #{player_num}"})
    end

    {:ok, view, html} = live(conn, "/players")

    assert has_element?(view, "#player-filter-form")
    assert has_element?(view, "#number-player-results", "#{@default_page_size+1}")

    refute has_element?(view, "#loading-icon", "Loading...")

    assert has_element?(view, "#per-page-dropbox")
    refute has_element?(view, "#pagination-left-arrow") # when you are on page 1, no option to see prev page
    assert has_element?(view, "#pagination-number-1")
    assert has_element?(view, "#pagination-number-2")
    refute has_element?(view, "#pagination-number-3")   # there are 2 pages available, not 3
    assert has_element?(view, "#pagination-right-arrow")

    assert has_element?(view, "#sort-by-dropbox")
    assert has_element?(view, "#download-link")
    assert has_element?(view, "#player-table")
  end

  test "insert a single player and see the player listed in query results table", %{conn: conn} do
    player_1 = create_test_player(%{player_name: "Player #1"})

    {:ok, view, html} = live(conn, "/players")

    assert has_element?(view, player_row(player_1))
  end

  defp player_row(player), do: "#player-#{player.id}"

#    view
#    |> form("#playerfilter", %{player_name: ""})
#    |> render_submit()


#  test "with no filtering, 326 players are queried", %{conn: conn} do
#    {:ok, view, html} = live(conn, "/players")
#
#    result = view
#             |> form("#playerfilter", %{player_name: ""})
##             |> element("#playerfilter")
##             |> render_submit(%{player_name: ""})
#             |> render_submit()
#
#   assert result =~ "326"
#  end

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

  def create_test_player(attrs) do
    {:ok, player} =
      attrs
      |> Enum.into(%{player_name: "TestPlayer",
          team_name: "TN1",
          player_position: "QB",
          rushing_attempts_per_game_avg: 0.0,
          rushing_attempts: 0,
          total_rushing_yards: 0,
          rushing_avg_yards_per_attempt: 0.0,
          rushing_yards_per_game: 0,
          total_rushing_touchdowns: 0,
          longest_rush: "0",
          rushing_first_downs: 0,
          rushing_first_down_percentage: 0.0,
          rushing_twenty_plus_yards_each: 0,
          rushing_forty_plus_yards_each: 0,
          rushing_fumbles: 0
      })
      |> NflRushing.PlayerStats.create_player()

    player
  end

end
