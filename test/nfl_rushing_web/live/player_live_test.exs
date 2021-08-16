defmodule NflRushingWeb.PlayerLiveTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  require Integer

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
    assert_patched(view, "/players?page=2&per_page=5")

    for player <- players do
      if player.player_name == "Player 6" do
        assert has_element?(view, player_row(player))
      else
        refute has_element?(view, player_row(player))
      end
    end
  end

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

    assert render(view) =~ ~r/alert-info.*No players matching.*Non-existent-player/

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

  # TODO:
  # Test sorting on each column
  # Test sorting and filtering
  # Test drop-box with more than 5 selected
  # Maybe add a render_component test.

  #  test "insert more than a page of players and see the first five players listed in query results table", %{conn: conn} do
  #    for player_num <- 1..(@default_page_size+1) do
  #      create_test_player(%{player_name: "Player #{player_num}", team_name: "T#{player_num}", total_rushing_yards: "#{player_num}",
  #          longest_rush: "#{player_num}",   })
  #
  #          rushing_attempts_per_game_avg: 0.0,
  #          rushing_attempts: 0,
  #          total_rushing_yards: 0,
  #          rushing_avg_yards_per_attempt: 0.0,
  #          rushing_yards_per_game: 0,
  #          total_rushing_touchdowns: 0,
  #          longest_rush: "0",
  #          rushing_first_downs: 0,
  #          rushing_first_down_percentage: 0.0,
  #          rushing_twenty_plus_yards_each: 0,
  #          rushing_forty_plus_yards_each: 0,
  #          rushing_fumbles: 0
  #
  #    end
  #
  #    player_1 = create_test_player(%{player_name: "Player #1"})
  #
  #    {:ok, view, html} = live(conn, "/players")
  #
  #    assert has_element?(view, player_row(player_1))
  #  end

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
  ### 2	Aaron Rodgers	GB	QB	4.2	67	369	5.5	23.1	4	23	25	37.3	3	0	3
  ### 3	Adam Humphries	TB	WR	0.3	5	18	3.6	1.2	0	8	0	0.0	0	0	0
  ### 4	Adam Thielen	MIN	WR	0.1	2	15	7.5	0.9	0	11	1	50.0	0	0	0
  ### 5	Adrian Peterson
  ### 6	Akeem Hunt
  ##  end

  #    IO.puts("Page list is.... [[#{inspect render(page_live), infinite: true}]]")
  #    IO.puts("Disconnected_html is.... [[#{inspect disconnected_html}]]")

  defp player_row(player), do: "#player-#{player.id}"

  def create_test_player(attrs) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        player_name: "TestPlayer",
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
