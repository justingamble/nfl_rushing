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
      set_sort_by: 2,
      set_player_filter: 2
    ]

  describe "Create 4 players for tests that apply a variety of filters and sorts" do
    setup %{conn: conn} do
      {player1, player2, player3, player4} = create_four_test_players()

      {:ok, view, _html} = live(conn, "/players")
      assert has_element?(view, "#number-player-results", "4")

      %{player1: player1, player2: player2, player3: player3, player4: player4, live_view: view}
    end

    # combination tested: player-name, 'not4'
    test "Sort by 'total rushing touchdowns, filter on 'not3', filter on 'not4', sort by 'player_name'",
         %{
           player1: player1,
           player2: player2,
           player3: player3,
           player4: player4,
           live_view: view
         } do
      set_sort_by(view, :total_rushing_touchdowns)
      set_player_filter(view, "not3")
      set_player_filter(view, "not4")
      set_sort_by(view, :player_name)

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
    test "Sort by 'total rushing yards', filter on 'not2'",
         %{
           player1: player1,
           player2: player2,
           player3: player3,
           player4: player4,
           live_view: view
         } do
      set_sort_by(view, :total_rushing_yards)
      set_player_filter(view, "not2")

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
    test "Filter on 'not1', Sort by 'longest rush'",
         %{
           player1: player1,
           player2: player2,
           player3: player3,
           player4: player4,
           live_view: view
         } do
      set_player_filter(view, "not1")
      set_sort_by(view, :longest_rush)

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
    test "Sort by 'longest rush', sort by 'total rushing touchdowns', filter on 'not3'",
         %{
           player1: player1,
           player2: player2,
           player3: player3,
           player4: player4,
           live_view: view
         } do
      set_sort_by(view, :longest_rush)
      set_sort_by(view, :total_rushing_touchdowns)
      set_player_filter(view, "not3")

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
end
