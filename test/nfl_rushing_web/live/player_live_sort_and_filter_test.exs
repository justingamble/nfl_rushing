defmodule NflRushingWeb.PlayerLiveSortAndFilterTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  require Integer

  import NflRushingWeb.PlayerLiveTestHelper,
    only: [
      create_four_test_players: 0,
      player_row: 1,
      player_index: 2,
      players_in_order: 3,
    ]

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
end
