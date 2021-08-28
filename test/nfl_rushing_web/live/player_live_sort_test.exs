defmodule NflRushingWeb.PlayerLiveSortTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  require Integer

  import NflRushingWeb.PlayerLiveTestHelper,
    only: [
      create_four_test_players: 0,
      create_test_player: 1,
      player_path: 1,
      player_row: 1,
      player_index: 2,
      players_in_order: 3,
      players_in_order: 4
    ]

  @default_page_size 5

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
end
