defmodule NflRushingWeb.PlayerLiveSortTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  require Integer

  import NflRushingWeb.PlayerLiveTestHelper,
    only: [
      create_four_test_players: 0,
      player_index: 2,
      players_in_order: 4,
      set_sort_by: 2
    ]

  describe "Sort by dropbox" do
    setup %{conn: conn} do
      {player1, player2, player3, player4} = create_four_test_players()

      {:ok, view, _html} = live(conn, "/players")
      assert has_element?(view, "#number-player-results", "4")

      %{player1: player1, player2: player2, player3: player3, player4: player4, live_view: view}
    end

    test "success: sort by 'player name'",
         %{
           player1: player1,
           player2: player2,
           player3: player3,
           player4: player4,
           live_view: view
         } do
      set_sort_by(view, :player_name)
      assert has_element?(view, "#number-player-results", "4")

      # Verify the order of the players is correct on the page
      assert render(view) =~ players_in_order(player2, player3, player4, player1)

      # Verify the correct table indexes are assigned to each player
      assert has_element?(view, player_index(player2, 1))
      assert has_element?(view, player_index(player3, 2))
      assert has_element?(view, player_index(player4, 3))
      assert has_element?(view, player_index(player1, 4))
    end

    test "success: sort by 'total rushing yards'",
         %{
           player1: player1,
           player2: player2,
           player3: player3,
           player4: player4,
           live_view: view
         } do
      set_sort_by(view, :total_rushing_yards)
      assert has_element?(view, "#number-player-results", "4")

      # Verify the order of the players is correct on the page
      assert render(view) =~ players_in_order(player3, player4, player2, player1)

      # Verify the correct table indexes are assigned to each player
      assert has_element?(view, player_index(player3, 1))
      assert has_element?(view, player_index(player4, 2))
      assert has_element?(view, player_index(player2, 3))
      assert has_element?(view, player_index(player1, 4))
    end

    test "success: sort by 'longest rush'",
         %{
           player1: player1,
           player2: player2,
           player3: player3,
           player4: player4,
           live_view: view
         } do
      set_sort_by(view, :longest_rush)
      assert has_element?(view, "#number-player-results", "4")

      # Verify the order of the players is correct on the page
      assert render(view) =~ players_in_order(player4, player1, player2, player3)

      # Verify the correct table indexes are assigned to each player
      assert has_element?(view, player_index(player4, 1))
      assert has_element?(view, player_index(player1, 2))
      assert has_element?(view, player_index(player2, 3))
      assert has_element?(view, player_index(player3, 4))
    end

    test "success: sort by 'total rushing touchdowns'",
         %{
           player1: player1,
           player2: player2,
           player3: player3,
           player4: player4,
           live_view: view
         } do
      set_sort_by(view, :total_rushing_touchdowns)
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
end
