defmodule NflRushingWeb.Api.DownloadControllerTest do
  use NflRushingWeb.ConnCase

  @download_path "/api/download"
  @download_file_header "Player,Team,Pos,Att/G,Att,Yds,Avg,Yds/G,TD,Lng,1st,1st%,20+,40+,FUM"
  @row_delimiter "\r\n"

  test "success: downloads a single player record and data is correct", %{conn: conn} do

    player1 = create_test_player(%{player_name: "Player #1"})

    # Player2 exists in this test just to show that the player filter excludes Player2 results
    _player2 = create_test_player(%{player_name: "Player #2"})

    response =
      conn
      |> put_req_header("content-type", "text/csv; charset=utf-8")
      |> get(@download_path, %{sort_by: :player_name, player_filter: player1.player_name})

    #IO.puts("My response in this test is.... #{inspect response, infinite: true, pretty: true}")

    expected_csv = @download_file_header <> @row_delimiter <> get_csv_row_for_player(player1) <> @row_delimiter
    assert response.resp_body == expected_csv
  end

  test "success: multiple players can be sorted and filtered in download results", %{conn: conn} do

    player1 = create_test_player(%{player_name: "Player Alfred", total_rushing_touchdowns: 50})
    player2 = create_test_player(%{player_name: "Player Bob", total_rushing_touchdowns: 40})
    player3 = create_test_player(%{player_name: "Player Christopher", total_rushing_touchdowns: 90})
    player4 = create_test_player(%{player_name: "Player David", total_rushing_touchdowns: 60})

    response =
      conn
      |> put_req_header("content-type", "text/csv; charset=utf-8")
      |> get(@download_path, %{sort_by: :total_rushing_touchdowns, player_filter: "Player"})

    IO.puts("My response in this test is.... #{inspect response, infinite: true, pretty: true}")

    expected_csv = @download_file_header <> @row_delimiter
                   <> get_csv_row_for_player(player2) <> @row_delimiter
                   <> get_csv_row_for_player(player1) <> @row_delimiter
                   <> get_csv_row_for_player(player4) <> @row_delimiter
                   <> get_csv_row_for_player(player3) <> @row_delimiter

    assert response.resp_body == expected_csv
  end

  def get_csv_row_for_player(player) do
    "#{player.player_name},"
    <> "#{player.team_name},"
    <> "#{player.player_position},"
    <> "#{player.rushing_attempts_per_game_avg},"
    <> "#{player.rushing_attempts},"
    <> "#{player.total_rushing_yards},"
    <> "#{player.rushing_avg_yards_per_attempt},"
    <> "#{player.rushing_yards_per_game},"
    <> "#{player.total_rushing_touchdowns},"
    <> "#{player.longest_rush},"
    <> "#{player.rushing_first_downs},"
    <> "#{player.rushing_first_down_percentage},"
    <> "#{player.rushing_twenty_plus_yards_each},"
    <> "#{player.rushing_forty_plus_yards_each},"
    <> "#{player.rushing_fumbles}"
  end

  def create_test_player(attrs) do
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
