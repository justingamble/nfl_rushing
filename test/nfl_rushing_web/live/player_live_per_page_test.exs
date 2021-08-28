defmodule NflRushingWeb.PlayerLivePerPageTest do
  use NflRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  require Integer

  import NflRushingWeb.PlayerLiveTestHelper,
    only: [create_test_player: 1, player_path: 1, player_row: 1]

  @default_page_size 5

  test "Change per-page setting of pagination", %{conn: conn} do
    num_players = @default_page_size * 2

    players =
      for player_num <- 1..num_players do
        create_test_player(%{player_name: "Player #{player_num}"})
      end

    {:ok, view, _html} = live(conn, "/players")

    view
    |> form("#per-page-dropbox", %{per_page_form: %{per_page: num_players}})
    |> render_change()

    assert_patched(view, player_path(%{page: 1, per_page: num_players}))

    for player <- players do
      assert has_element?(view, player_row(player))
    end
  end
end
