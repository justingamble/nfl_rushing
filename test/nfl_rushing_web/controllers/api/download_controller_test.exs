defmodule NflRushingWeb.Api.DownloadControllerTest do
  use NflRushingWeb.ConnCase

  alias NflRushingWeb.Endpoint

  @download_path "/api/download"
  @row_delimiter "\r\n"
  @file_header_row "Player,Team,Pos,Att/G,Att,Yds,Avg,Yds/G,TD,Lng,1st,1st%,20+,40+,FUM#{
                     @row_delimiter
                   }"
  @download_results_topic "download_results"

  describe "Validate the data that is downloaded" do
    test "success: downloads a single player record and downloaded data is correct", %{conn: conn} do
      player1 = create_test_player(%{player_name: "Player #1"})

      # Player2 exists in this test just to show that the player filter excludes Player2 results
      _player2 = create_test_player(%{player_name: "Player #2"})

      response =
        conn
        |> put_req_header("content-type", "text/csv; charset=utf-8")
        |> get(@download_path, %{sort_by: :player_name, player_filter: player1.player_name})

      expected_csv = @file_header_row <> get_csv_row_for_player(player1)

      assert response.resp_body == expected_csv
    end

    test "success: multiple players can be sorted and filtered in download results", %{conn: conn} do
      player1 = create_test_player(%{player_name: "Player Alfred", total_rushing_touchdowns: 50})
      player2 = create_test_player(%{player_name: "Player Bob", total_rushing_touchdowns: 40})
      player3 = create_test_player(%{player_name: "Player Chris", total_rushing_touchdowns: 90})
      player4 = create_test_player(%{player_name: "Player David", total_rushing_touchdowns: 60})

      response =
        conn
        |> put_req_header("content-type", "text/csv; charset=utf-8")
        |> get(@download_path, %{sort_by: :total_rushing_touchdowns, player_filter: "Player"})

      expected_csv =
        @file_header_row <>
          get_csv_row_for_player(player2) <>
          get_csv_row_for_player(player1) <>
          get_csv_row_for_player(player4) <>
          get_csv_row_for_player(player3)

      assert response.resp_body == expected_csv
    end
  end

  describe "Invalid download URI provided" do
    # Expectation comes from:
    # https://stackoverflow.com/questions/11746894/what-is-the-proper-rest-response-code-for-a-valid-request-but-an-empty-data
    test "exception: if player filter does not resolve to a player, return status 404", %{
      conn: conn
    } do
      _player1 = create_test_player(%{player_name: "Player Alfred", total_rushing_touchdowns: 50})
      _player2 = create_test_player(%{player_name: "Player Bob", total_rushing_touchdowns: 40})

      response =
        conn
        |> put_req_header("content-type", "text/csv; charset=utf-8")
        |> get(@download_path, %{
          sort_by: :total_rushing_touchdowns,
          player_filter: "No Such Player"
        })

      assert response.status == 404
      refute response.resp_body
    end
  end

  describe "Broadcast messages sent to Phoenix PubSub" do
    test "success: download behaviour will publish an event to PubSub", %{conn: conn} do
      _player_1 = create_test_player(%{player_name: "Player #1"})

      Endpoint.subscribe(@download_results_topic)

      conn
      |> put_req_header("content-type", "text/csv; charset=utf-8")
      |> get("/api/download/", %{sort_by: :total_rushing_touchdowns, player_filter: "Player"})

      expected_payload = %Phoenix.Socket.Broadcast{
        event: "players_downloaded",
        payload: %{},
        topic: @download_results_topic
      }

      assert_receive ^expected_payload, 5_000
      Endpoint.unsubscribe(@download_results_topic)
    end
  end

  defp get_csv_row_for_player(player) do
    "#{player.player_name}," <>
      "#{player.team_name}," <>
      "#{player.player_position}," <>
      "#{player.rushing_attempts_per_game_avg}," <>
      "#{player.rushing_attempts}," <>
      "#{player.total_rushing_yards}," <>
      "#{player.rushing_avg_yards_per_attempt}," <>
      "#{player.rushing_yards_per_game}," <>
      "#{player.total_rushing_touchdowns}," <>
      "#{player.longest_rush}," <>
      "#{player.rushing_first_downs}," <>
      "#{player.rushing_first_down_percentage}," <>
      "#{player.rushing_twenty_plus_yards_each}," <>
      "#{player.rushing_forty_plus_yards_each}," <>
      "#{player.rushing_fumbles}" <>
      @row_delimiter
  end

  defp create_test_player(attrs) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        player_name: "TestPlayer",
        team_name: "TN1",
        player_position: "QB",
        rushing_attempts_per_game_avg: 1.2,
        rushing_attempts: 3,
        total_rushing_yards: 4,
        rushing_avg_yards_per_attempt: 5.6,
        rushing_yards_per_game: 7,
        total_rushing_touchdowns: 8,
        longest_rush: "9",
        rushing_first_downs: 10,
        rushing_first_down_percentage: 11.12,
        rushing_twenty_plus_yards_each: 14,
        rushing_forty_plus_yards_each: 15,
        rushing_fumbles: 16
      })
      |> NflRushing.PlayerStats.create_player()

    player
  end
end
