defmodule NflRushingWeb.PlayerLiveDownloadTest do
  use NflRushingWeb.ConnCase

  require Integer

  import Phoenix.LiveViewTest

  import NflRushingWeb.PlayerLiveTestHelper,
    only: [
      create_test_player: 1,
      set_sort_by: 2,
      set_player_filter: 2
    ]

  alias NflRushingWeb.Endpoint

  @download_results_topic "download_results"

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

  describe "Flash message is shown" do
    test "success: after broadcast to Phoenix PubSub, flash message is shown", %{conn: conn} do
      _player_1 = create_test_player(%{player_name: "Player #1"})
      {:ok, view, _html} = live(conn, "/players")

      Endpoint.broadcast(@download_results_topic, "players_downloaded", %{})

      assert render(view) =~ "Player data downloaded successfully"
    end

  end
end
