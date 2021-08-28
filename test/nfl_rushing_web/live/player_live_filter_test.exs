defmodule NflRushingWeb.PlayerLiveFilterTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  require Integer

  import NflRushingWeb.PlayerLiveTestHelper,
    only: [create_test_player: 1, player_row: 1]

  @default_page_size 5

  describe "Test 'Filter Players' button when # of players exceeds what can fit on a pagination page" do
    setup context = %{conn: conn} do
      players =
        for player_num <- 1..(@default_page_size + 1) do
          create_test_player(%{player_name: "Player #{player_num}"})
        end

      {:ok, view, _html} = live(conn, "/players")
      assert has_element?(view, "#number-player-results", "#{@default_page_size + 1}")

      Map.merge(context, %{
        players: players,
        live_view: view
      })
    end

    test "exception: filtering with no matches will show flash message, and not display any players",
         %{
           players: players,
           live_view: view
         } do
      view
      |> form("#player-filter-form", %{player_name: "Non-existent-player"})
      |> render_submit()

      assert has_element?(view, "#number-player-results", "0")

      assert render(view) =~ ~r/alert-info.*No players matching.*Non-existent-player/s

      for player <- players do
        refute has_element?(view, player_row(player))
      end

      refute has_element?(view, "#player-table")
    end

    test "success: filtering by exact player name will display the single player", %{
      players: players,
      live_view: view
    } do
      expected_player_name = "Player #{@default_page_size + 1}"

      view
      |> form("#player-filter-form", %{player_name: expected_player_name})
      |> render_submit()

      assert has_element?(view, "#number-player-results", "1")

      for player <- players do
        if player.player_name == expected_player_name do
          assert has_element?(view, player_row(player))
        else
          refute has_element?(view, player_row(player))
        end
      end
    end
  end

  describe "Test 'Filter Players' button when mutiple players are matched (case-sensitive)" do
    setup context = %{conn: conn} do
      players =
        for player_num <- 1..@default_page_size do
          if Integer.is_even(player_num) do
            create_test_player(%{player_name: "Matched Player #{player_num}"})
          else
            create_test_player(%{player_name: "Excluded Player #{player_num}"})
          end
        end

      {:ok, view, _html} = live(conn, "/players")
      assert has_element?(view, "#number-player-results", "#{@default_page_size}")

      Map.merge(context, %{
        players: players,
        live_view: view
      })
    end

    test "success: filtering by substring that matches start of multiple player names", %{
      players: players,
      live_view: view
    } do
      view
      |> form("#player-filter-form", %{player_name: "Matched Player"})
      |> render_submit()

      expected_num_results = Integer.floor_div(@default_page_size, 2)
      assert has_element?(view, "#number-player-results", "#{expected_num_results}")

      for player <- players do
        if player.player_name =~ ~r/Matched/i do
          assert has_element?(view, player_row(player))
        else
          refute has_element?(view, player_row(player))
        end
      end
    end

    test "Filtering by substring that matches middle of multipler player names (with spaces surrounding match word)",
         %{
           players: players,
           live_view: view
         } do
      view
      |> form("#player-filter-form", %{player_name: " atched play "})
      |> render_submit()

      expected_num_results = Integer.floor_div(@default_page_size, 2)
      assert has_element?(view, "#number-player-results", "#{expected_num_results}")

      for player <- players do
        if player.player_name =~ ~r/Matched/i do
          assert has_element?(view, player_row(player))
        else
          refute has_element?(view, player_row(player))
        end
      end
    end
  end

  describe "Test 'Filter Players' button when mutiple players are matched (case-insensitive)" do
    test "Filtering by substring that matches start of multiple player names (case insensitive)",
         %{
           conn: conn
         } do
      players =
        for player_num <- 1..@default_page_size do
          if Integer.is_even(player_num) do
            create_test_player(%{player_name: "MaTcHeD Player #{player_num}"})
          else
            create_test_player(%{player_name: "Excluded Player #{player_num}"})
          end
        end

      {:ok, view, _html} = live(conn, "/players")

      assert has_element?(view, "#number-player-results", "#{@default_page_size}")

      view
      |> form("#player-filter-form", %{player_name: "matcHED plaYER"})
      |> render_submit()

      expected_num_results = Integer.floor_div(@default_page_size, 2)
      assert has_element?(view, "#number-player-results", "#{expected_num_results}")

      for player <- players do
        if player.player_name =~ ~r/matched/i do
          assert has_element?(view, player_row(player))
        else
          refute has_element?(view, player_row(player))
        end
      end
    end
  end
end
