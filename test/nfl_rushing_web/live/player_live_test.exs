defmodule NflRushingWeb.PlayerLiveTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  require Integer

  import NflRushingWeb.PlayerLiveTestHelper,
    only: [
      create_four_test_players: 0,
      create_test_player: 1,
      player_path: 1,
      player_row: 1,
      player_index: 2
    ]

  @default_page_size 5

  test "/ redirects to /players", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/players"}}} = live(conn, "/")
  end

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/players")

    assert disconnected_html =~ "NFL Rushing Statistics"
    # in root.html.leex template; not part of liveview output
    refute render(page_live) =~ "NFL Rushing Statistics"

    assert disconnected_html =~ "Filter players"
    assert render(page_live) =~ "Filter players"
  end

  test "with no players in database, check that the correct form components are shown", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, "/players")

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

  test "with a single player in database, check that the correct form components are shown", %{
    conn: conn
  } do
    _player_1 = create_test_player(%{player_name: "Player #1"})

    {:ok, view, _html} = live(conn, "/players")

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

  test "with more than 1 page of players in database, check that the correct form components are shown",
       %{conn: conn} do
    for player_num <- 1..(@default_page_size + 1) do
      create_test_player(%{player_name: "Player #{player_num}"})
    end

    {:ok, view, _html} = live(conn, "/players")

    assert has_element?(view, "#player-filter-form")
    assert has_element?(view, "#number-player-results", "#{@default_page_size + 1}")

    refute has_element?(view, "#loading-icon", "Loading...")

    assert has_element?(view, "#per-page-dropbox")
    # when you are on page 1, no option to see prev page
    refute has_element?(view, "#pagination-left-arrow")
    assert has_element?(view, "#pagination-number-1")
    assert has_element?(view, "#pagination-number-2")
    # there are 2 pages available, not 3
    refute has_element?(view, "#pagination-number-3")
    assert has_element?(view, "#pagination-right-arrow")

    assert has_element?(view, "#sort-by-dropbox")
    assert has_element?(view, "#download-link")
    assert has_element?(view, "#player-table")
  end

  test "the left-pagination-button is shown if we are on page > 1", %{conn: conn} do
    for player_num <- 1..(@default_page_size + 1) do
      create_test_player(%{player_name: "Player #{player_num}"})
    end

    {:ok, view, _html} = live(conn, "/players")

    refute has_element?(view, "#pagination-left-arrow")

    view |> element("#pagination-right-arrow") |> render_click()

    assert has_element?(view, "#pagination-left-arrow")
  end

  test "insert a single player and see the player listed in query results table", %{conn: conn} do
    player_1 = create_test_player(%{player_name: "Player #1"})

    {:ok, view, _html} = live(conn, "/players")

    assert has_element?(view, player_row(player_1))
  end

  test "insert more than a page of players; only see the page-2 players when right-arrow-pagination button pressed",
       %{conn: conn} do
    players =
      for player_num <- 1..(@default_page_size + 1) do
        create_test_player(%{player_name: "Player #{player_num}"})
      end

    {:ok, view, _html} = live(conn, "/players")

    for player <- players do
      if player.player_name != "Player 6" do
        assert has_element?(view, player_row(player))
      else
        refute has_element?(view, player_row(player))
      end
    end

    view |> element("#pagination-right-arrow") |> render_click()
    assert_patched(view, "/players?page=2&per_page=5")

    for player <- players do
      if player.player_name == "Player 6" do
        assert has_element?(view, player_row(player))
      else
        refute has_element?(view, player_row(player))
      end
    end
  end

  test "insert more than a page of players; only see the page 2 players when page-2-pagination button pressed",
       %{conn: conn} do
    players =
      for player_num <- 1..(@default_page_size + 1) do
        create_test_player(%{player_name: "Player #{player_num}"})
      end

    {:ok, view, _html} = live(conn, "/players")

    for player <- players do
      if player.player_name != "Player 6" do
        assert has_element?(view, player_row(player))
      else
        refute has_element?(view, player_row(player))
      end
    end

    view |> element("#pagination-number-2") |> render_click()
    assert_patched(view, player_path(%{page: 2, per_page: 5}))

    for player <- players do
      if player.player_name == "Player 6" do
        assert has_element?(view, player_row(player))
      else
        refute has_element?(view, player_row(player))
      end
    end
  end
end
