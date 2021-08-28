defmodule NflRushingWeb.PlayerLiveTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  require Integer

  import NflRushingWeb.PlayerLiveTestHelper,
    only: [create_test_player: 1, player_path: 1, player_row: 1, player_index: 2]

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

  test "Sort by 'player name'",
       %{conn: conn} do
    {player1, player2, player3, player4} = create_four_test_players()

    {:ok, view, _html} = live(conn, "/players")

    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: :player_name}})
    |> render_change()

    assert has_element?(view, "#number-player-results", "4")

    # Verify the order of the players is correct on the page
    assert render(view) =~ players_in_order(player2, player3, player4, player1)

    # Verify the correct table indexes are assigned to each player
    assert has_element?(view, player_index(player2, 1))
    assert has_element?(view, player_index(player3, 2))
    assert has_element?(view, player_index(player4, 3))
    assert has_element?(view, player_index(player1, 4))
  end

  test "Sort by 'total rushing yards'",
       %{conn: conn} do
    {player1, player2, player3, player4} = create_four_test_players()

    {:ok, view, _html} = live(conn, "/players")

    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: :total_rushing_yards}})
    |> render_change()

    assert has_element?(view, "#number-player-results", "4")

    # Verify the order of the players is correct on the page
    assert render(view) =~ players_in_order(player3, player4, player2, player1)

    # Verify the correct table indexes are assigned to each player
    assert has_element?(view, player_index(player3, 1))
    assert has_element?(view, player_index(player4, 2))
    assert has_element?(view, player_index(player2, 3))
    assert has_element?(view, player_index(player1, 4))
  end

  test "Sort by 'longest rush'",
       %{conn: conn} do
    {player1, player2, player3, player4} = create_four_test_players()

    {:ok, view, _html} = live(conn, "/players")

    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: :longest_rush}})
    |> render_change()

    assert has_element?(view, "#number-player-results", "4")

    # Verify the order of the players is correct on the page
    assert render(view) =~ players_in_order(player4, player1, player2, player3)

    # Verify the correct table indexes are assigned to each player
    assert has_element?(view, player_index(player4, 1))
    assert has_element?(view, player_index(player1, 2))
    assert has_element?(view, player_index(player2, 3))
    assert has_element?(view, player_index(player3, 4))
  end

  test "Sort by 'total rushing touchdowns'",
       %{conn: conn} do
    {player1, player2, player3, player4} = create_four_test_players()

    {:ok, view, _html} = live(conn, "/players")

    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: :total_rushing_touchdowns}})
    |> render_change()

    assert has_element?(view, "#number-player-results", "4")

    # Verify the order of the players is correct on the page
    assert render(view) =~ players_in_order(player1, player3, player4, player2)

    # Verify the correct table indexes are assigned to each player
    assert has_element?(view, player_index(player1, 1))
    assert has_element?(view, player_index(player3, 2))
    assert has_element?(view, player_index(player4, 3))
    assert has_element?(view, player_index(player2, 4))
  end

  # combination tested: player-name, 'not4'
  test "Sort by 'total rushing touchdowns, then filter on 'not3', then filter on 'not4', then sort by 'player_name'",
       %{conn: conn} do
    {player1, player2, player3, player4} = create_four_test_players()

    {:ok, view, _html} = live(conn, "/players")

    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: :total_rushing_touchdowns}})
    |> render_change()

    view
    |> form("#player-filter-form", %{player_name: "not3"})
    |> render_submit()

    view
    |> form("#player-filter-form", %{player_name: "not4"})
    |> render_submit()

    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: :player_name}})
    |> render_change()

    assert has_element?(view, "#number-player-results", "3")

    # Verify the order of the players is correct on the page
    assert render(view) =~ players_in_order(player2, player3, player1)

    # Verify the correct table indexes are assigned to each player
    assert has_element?(view, player_index(player2, 1))
    assert has_element?(view, player_index(player3, 2))
    assert has_element?(view, player_index(player1, 3))
    refute has_element?(view, player_row(player4))
  end

  # combination tested: total_rushing_yards, 'not2'
  test "Sort by 'total rushing yards', then filter on 'not2'",
       %{conn: conn} do
    {player1, player2, player3, player4} = create_four_test_players()

    {:ok, view, _html} = live(conn, "/players")

    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: :total_rushing_yards}})
    |> render_change()

    view
    |> form("#player-filter-form", %{player_name: "not2"})
    |> render_submit()

    assert has_element?(view, "#number-player-results", "3")

    # Verify the order of the players is correct on the page
    assert render(view) =~ players_in_order(player3, player4, player1)

    # Verify the correct table indexes are assigned to each player
    assert has_element?(view, player_index(player3, 1))
    assert has_element?(view, player_index(player4, 2))
    assert has_element?(view, player_index(player1, 3))
    refute has_element?(view, player_row(player2))
  end

  # combination tested: longest_rush, 'not1'
  test "Filter on 'not1', then Sort by 'longest rush'",
       %{conn: conn} do
    {player1, player2, player3, player4} = create_four_test_players()

    {:ok, view, _html} = live(conn, "/players")

    view
    |> form("#player-filter-form", %{player_name: "not1"})
    |> render_submit()

    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: :longest_rush}})
    |> render_change()

    assert has_element?(view, "#number-player-results", "3")

    # Verify the order of the players is correct on the page
    assert render(view) =~ players_in_order(player4, player2, player3)

    # Verify the correct table indexes are assigned to each player
    assert has_element?(view, player_index(player4, 1))
    assert has_element?(view, player_index(player2, 2))
    assert has_element?(view, player_index(player3, 3))
    refute has_element?(view, player_row(player1))
  end

  # combination tested: total_rushing_touchdowns, 'not3'
  test "Sort by 'longest rush', then sort by 'total rushing touchdowns', then filter on 'not3'",
       %{conn: conn} do
    {player1, player2, player3, player4} = create_four_test_players()

    {:ok, view, _html} = live(conn, "/players")

    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: :longest_rush}})
    |> render_change()

    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: :total_rushing_touchdowns}})
    |> render_change()

    view
    |> form("#player-filter-form", %{player_name: "not3"})
    |> render_submit()

    assert has_element?(view, "#number-player-results", "3")

    # Verify the order of the players is correct on the page
    assert render(view) =~ players_in_order(player1, player4, player2)

    # Verify the correct table indexes are assigned to each player
    assert has_element?(view, player_index(player1, 1))
    assert has_element?(view, player_index(player4, 2))
    assert has_element?(view, player_index(player2, 3))
    refute has_element?(view, player_row(player3))
  end

  defp players_in_order(first, second, third) do
    ~r/#{first.player_name}.*#{second.player_name}.*#{third.player_name}/s
  end

  defp players_in_order(first, second, third, fourth) do
    ~r/#{first.player_name}.*#{second.player_name}.*#{third.player_name}.*#{fourth.player_name}/s
  end

  defp create_four_test_players() do
    player1 =
      create_test_player(%{
        player_name: "David not2 not3 not4 Duncan",
        total_rushing_yards: 70,
        longest_rush: "53",
        total_rushing_touchdowns: 25
      })

    player2 =
      create_test_player(%{
        player_name: "Albert not1 not3 not4 Alfredson",
        total_rushing_yards: 69,
        longest_rush: "55T",
        total_rushing_touchdowns: 75
      })

    player3 =
      create_test_player(%{
        player_name: "Bob not1 not2 not4 Bippo",
        total_rushing_yards: 60,
        longest_rush: "59",
        total_rushing_touchdowns: 49
      })

    player4 =
      create_test_player(%{
        player_name: "Calvin not1 not2 not3 Cornelius",
        total_rushing_yards: 65,
        longest_rush: "50T",
        total_rushing_touchdowns: 50
      })

    {player1, player2, player3, player4}
  end

end
