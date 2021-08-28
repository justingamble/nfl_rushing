defmodule NflRushingWeb.PlayerLiveFilterTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  require Integer

  import NflRushingWeb.PlayerLiveTestHelper,
    only: [create_test_player: 1, player_path: 1, player_row: 1, player_index: 2]

  @default_page_size 5

  test "Filtering with no matches will show flash message, and not display any players", %{
    conn: conn
  } do
    players =
      for player_num <- 1..(@default_page_size + 1) do
        create_test_player(%{player_name: "Player #{player_num}"})
      end

    {:ok, view, _html} = live(conn, "/players")
    assert has_element?(view, "#number-player-results", "#{@default_page_size + 1}")

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

  test "Filtering by exact player name will display the single player", %{conn: conn} do
    players =
      for player_num <- 1..(@default_page_size + 1) do
        create_test_player(%{player_name: "Player #{player_num}"})
      end

    {:ok, view, _html} = live(conn, "/players")
    assert has_element?(view, "#number-player-results", "#{@default_page_size + 1}")

    view
    |> form("#player-filter-form", %{player_name: "Player 3"})
    |> render_submit()

    assert has_element?(view, "#number-player-results", "1")

    for player <- players do
      if player.player_name == "Player 3" do
        assert has_element?(view, player_row(player))
      else
        refute has_element?(view, player_row(player))
      end
    end
  end

  test "Filtering by substring that matches start of multipler player names (case sensitive)", %{
    conn: conn
  } do
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

  test "Filtering by substring that matches start of multipler player names (case insensitive)",
       %{conn: conn} do
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

  test "Filtering by substring that matches middle of multipler player names (with spaces surrounding match word)",
       %{conn: conn} do
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

  #  defp players_in_order(first, second, third) do
  #    ~r/#{first.player_name}.*#{second.player_name}.*#{third.player_name}/s
  #  end
  #
  #  defp players_in_order(first, second, third, fourth) do
  #    ~r/#{first.player_name}.*#{second.player_name}.*#{third.player_name}.*#{fourth.player_name}/s
  #  end
  #
  #  defp create_four_test_players() do
  #    player1 =
  #      create_test_player(%{
  #        player_name: "David not2 not3 not4 Duncan",
  #        total_rushing_yards: 70,
  #        longest_rush: "53",
  #        total_rushing_touchdowns: 25
  #      })
  #
  #    player2 =
  #      create_test_player(%{
  #        player_name: "Albert not1 not3 not4 Alfredson",
  #        total_rushing_yards: 69,
  #        longest_rush: "55T",
  #        total_rushing_touchdowns: 75
  #      })
  #
  #    player3 =
  #      create_test_player(%{
  #        player_name: "Bob not1 not2 not4 Bippo",
  #        total_rushing_yards: 60,
  #        longest_rush: "59",
  #        total_rushing_touchdowns: 49
  #      })
  #
  #    player4 =
  #      create_test_player(%{
  #        player_name: "Calvin not1 not2 not3 Cornelius",
  #        total_rushing_yards: 65,
  #        longest_rush: "50T",
  #        total_rushing_touchdowns: 50
  #      })
  #
  #    {player1, player2, player3, player4}
  #  end
end
