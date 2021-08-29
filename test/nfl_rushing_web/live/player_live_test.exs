defmodule NflRushingWeb.PlayerLiveTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  require Integer

  import NflRushingWeb.PlayerLiveTestHelper,
    only: [
      create_test_player: 1,
      player_path: 1,
      player_row: 1
    ]

  @default_page_size 5

  describe "Sanity checks" do
    test "success: / redirects to /players", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/players"}}} = live(conn, "/")
    end

    test "success: disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, "/players")

      assert disconnected_html =~ "NFL Rushing Statistics"
      # "NFL Rushing Statistics" is in the root.html.leex template; not part of liveview output
      refute render(page_live) =~ "NFL Rushing Statistics"

      assert disconnected_html =~ "Filter players"
      assert render(page_live) =~ "Filter players"
    end
  end

  describe "Test which form conponents are visible" do
    test "exception: no players in the database", %{
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

    test "exception: a single player in the database", %{conn: conn} do
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

    test "success: more than 1 page of players in database",
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

    test "success: the left-pagination-button is only shown if we are on page > 1", %{conn: conn} do
      for player_num <- 1..(@default_page_size + 1) do
        create_test_player(%{player_name: "Player #{player_num}"})
      end

      {:ok, view, _html} = live(conn, "/players")
      refute has_element?(view, "#pagination-left-arrow")

      view |> element("#pagination-right-arrow") |> render_click()
      assert has_element?(view, "#pagination-left-arrow")
    end
  end

  describe "Test the contents of the player table, with a single page of player data" do
    test "success: a single player in database is listed in the query results table", %{
      conn: conn
    } do
      player_1 = create_test_player(%{player_name: "Player #1"})

      {:ok, view, _html} = live(conn, "/players")

      assert has_element?(view, player_row(player_1))
    end
  end

  describe "Test the contents of the player table, with two pages of player data" do
    setup %{conn: conn} do
      max_player_num = @default_page_size + 1

      players =
        for player_num <- 1..max_player_num do
          create_test_player(%{player_name: "Player #{player_num}"})
        end

      {:ok, view, _html} = live(conn, "/players")
      assert has_element?(view, "#number-player-results", "#{max_player_num}")

      %{
        max_player_num: max_player_num,
        players: players,
        live_view: view
      }
    end

    test "success: press right-arrow-pagination-button in order to see page-2 players",
         %{max_player_num: max_player_num, players: players, live_view: view} do
      for player <- players do
        if player.player_name == "Player #{max_player_num}" do
          refute has_element?(view, player_row(player))
        else
          assert has_element?(view, player_row(player))
        end
      end

      view |> element("#pagination-right-arrow") |> render_click()
      assert_patched(view, player_path(%{page: 2, per_page: @default_page_size}))

      for player <- players do
        if player.player_name == "Player #{max_player_num}" do
          assert has_element?(view, player_row(player))
        else
          refute has_element?(view, player_row(player))
        end
      end
    end

    test "success: press page-2-pagination-link in order to see page-2 players",
         %{max_player_num: max_player_num, players: players, live_view: view} do
      for player <- players do
        if player.player_name == "Player #{max_player_num}" do
          refute has_element?(view, player_row(player))
        else
          assert has_element?(view, player_row(player))
        end
      end

      view |> element("#pagination-number-2") |> render_click()
      assert_patched(view, player_path(%{page: 2, per_page: @default_page_size}))

      for player <- players do
        if player.player_name == "Player #{max_player_num}" do
          assert has_element?(view, player_row(player))
        else
          refute has_element?(view, player_row(player))
        end
      end
    end
  end
end
