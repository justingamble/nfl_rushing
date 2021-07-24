defmodule NflRushingWeb.PlayerLiveTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest

  alias NflRushing.PlayerStats

  @create_attrs %{
    longest_rush: "some longest_rush",
    player_name: "some player_name",
    player_position: "some player_position",
    rushing_attempts: 42,
    rushing_attempts_per_game_avg: 120.5,
    rushing_avg_yards_per_attempt: 120.5,
    rushing_first_down_percentage: 120.5,
    rushing_first_downs: 42,
    rushing_forty_plus_yards_each: 42,
    rushing_fumbles: 42,
    rushing_twenty_plus_yards_each: 42,
    rushing_yards_per_game: 120.5,
    team_name: "some team_name",
    total_rushing_touchdowns: 42,
    total_rushing_yards: 42
  }
  @update_attrs %{
    longest_rush: "some updated longest_rush",
    player_name: "some updated player_name",
    player_position: "some updated player_position",
    rushing_attempts: 43,
    rushing_attempts_per_game_avg: 456.7,
    rushing_avg_yards_per_attempt: 456.7,
    rushing_first_down_percentage: 456.7,
    rushing_first_downs: 43,
    rushing_forty_plus_yards_each: 43,
    rushing_fumbles: 43,
    rushing_twenty_plus_yards_each: 43,
    rushing_yards_per_game: 456.7,
    team_name: "some updated team_name",
    total_rushing_touchdowns: 43,
    total_rushing_yards: 43
  }
  @invalid_attrs %{
    longest_rush: nil,
    player_name: nil,
    player_position: nil,
    rushing_attempts: nil,
    rushing_attempts_per_game_avg: nil,
    rushing_avg_yards_per_attempt: nil,
    rushing_first_down_percentage: nil,
    rushing_first_downs: nil,
    rushing_forty_plus_yards_each: nil,
    rushing_fumbles: nil,
    rushing_twenty_plus_yards_each: nil,
    rushing_yards_per_game: nil,
    team_name: nil,
    total_rushing_touchdowns: nil,
    total_rushing_yards: nil
  }

  defp fixture(:player) do
    {:ok, player} = PlayerStats.create_player(@create_attrs)
    player
  end

  defp create_player(_) do
    player = fixture(:player)
    %{player: player}
  end

  describe "Index" do
    setup [:create_player]

    test "lists all players", %{conn: conn, player: player} do
      {:ok, _index_live, html} = live(conn, Routes.player_index_path(conn, :index))

      assert html =~ "Listing Players"
      assert html =~ player.longest_rush
    end

    test "saves new player", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.player_index_path(conn, :index))

      assert index_live |> element("a", "New Player") |> render_click() =~
               "New Player"

      assert_patch(index_live, Routes.player_index_path(conn, :new))

      assert index_live
             |> form("#player-form", player: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#player-form", player: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.player_index_path(conn, :index))

      assert html =~ "Player created successfully"
      assert html =~ "some longest_rush"
    end

    test "updates player in listing", %{conn: conn, player: player} do
      {:ok, index_live, _html} = live(conn, Routes.player_index_path(conn, :index))

      assert index_live |> element("#player-#{player.id} a", "Edit") |> render_click() =~
               "Edit Player"

      assert_patch(index_live, Routes.player_index_path(conn, :edit, player))

      assert index_live
             |> form("#player-form", player: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#player-form", player: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.player_index_path(conn, :index))

      assert html =~ "Player updated successfully"
      assert html =~ "some updated longest_rush"
    end

    test "deletes player in listing", %{conn: conn, player: player} do
      {:ok, index_live, _html} = live(conn, Routes.player_index_path(conn, :index))

      assert index_live |> element("#player-#{player.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#player-#{player.id}")
    end
  end

  describe "Show" do
    setup [:create_player]

    test "displays player", %{conn: conn, player: player} do
      {:ok, _show_live, html} = live(conn, Routes.player_show_path(conn, :show, player))

      assert html =~ "Show Player"
      assert html =~ player.longest_rush
    end

    test "updates player within modal", %{conn: conn, player: player} do
      {:ok, show_live, _html} = live(conn, Routes.player_show_path(conn, :show, player))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Player"

      assert_patch(show_live, Routes.player_show_path(conn, :edit, player))

      assert show_live
             |> form("#player-form", player: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#player-form", player: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.player_show_path(conn, :show, player))

      assert html =~ "Player updated successfully"
      assert html =~ "some updated longest_rush"
    end
  end
end
