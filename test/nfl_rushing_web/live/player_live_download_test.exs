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

  describe "Redirects to the download controller with the correct sort/filter parameters" do
    setup %{conn: conn} do
      _player_1 = create_test_player(%{player_name: "Player #1"})
      {:ok, view, _html} = live(conn, "/players")

      %{liveview: view}
    end

    test "success: sort_by specified by default, player_filter is blank", %{liveview: view} do
      result = view |> element("#download-link") |> render_click()

      assert result ==
               {:error, {:redirect, %{to: "/api/download?sort_by=player_name&player_filter="}}}
    end

    test "success: sort_by is total_rushing_yards, player_filter is 'Player #1'", %{
      liveview: view
    } do
      set_sort_by(view, :total_rushing_yards)
      set_player_filter(view, "Player #1")

      result = view |> element("#download-link") |> render_click()

      assert result ==
               {:error,
                {:redirect,
                 %{to: "/api/download?sort_by=total_rushing_yards&player_filter=Player%20#1"}}}
    end

    test "success: sort_by is total_rushing_touchdowns, player_filter is 'Player #1'", %{
      liveview: view
    } do
      set_sort_by(view, :total_rushing_touchdowns)
      set_player_filter(view, "Player #1")

      result = view |> element("#download-link") |> render_click()

      assert result ==
               {:error,
                {:redirect,
                 %{to: "/api/download?sort_by=total_rushing_touchdowns&player_filter=Player%20#1"}}}
    end

    test "success: sort_by is longest rush, player_filter is 'Player #1'", %{liveview: view} do
      set_sort_by(view, :longest_rush)
      set_player_filter(view, "Player #1")

      result = view |> element("#download-link") |> render_click()

      assert result ==
               {:error,
                {:redirect, %{to: "/api/download?sort_by=longest_rush&player_filter=Player%20#1"}}}
    end
  end

  defp set_sort_by(view, sort_by) when is_atom(sort_by) do
    view
    |> form("#sort-by-dropbox", %{sort_by_form: %{sort_by: sort_by}})
    |> render_change()
  end

  defp set_player_filter(view, player_filter) when is_binary(player_filter) do
    view
    |> form("#player-filter-form", %{player_name: player_filter})
    |> render_submit()
  end

  #  describe "Flash message is down after file download" do
  #
  #    test "After download pressed, a flash message is visible", %{conn: conn} do
  #        _player_1 = create_test_player(%{player_name: "Player #1"})
  #
  #        {:ok, view, _html} = live(conn, "/players")
  ##       =~ "Player data downloaded successfully#"
  #
  #        view |> element("#download-link") |> render_click() =~ "Player data downloaded successfully"
  #  #      view
  #      |> form("#player-filter-form", %{player_name: expected_player_name})
  #      |> render_submit()
  #    end
  #
  #    end
  #  end
end
