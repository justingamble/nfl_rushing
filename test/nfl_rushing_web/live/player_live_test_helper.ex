defmodule NflRushingWeb.PlayerLiveTestHelper do
  def player_path(%{page: page_number, per_page: per_page}) do
    "/players?" <> "page=#{page_number}&per_page=#{per_page}"
  end

  def player_row(player), do: "#player-#{player.id}"

  def player_index(player, index), do: "#player-#{player.id}-index-#{index}"

  def players_in_order(first, second, third) do
    ~r/#{first.player_name}.*#{second.player_name}.*#{third.player_name}/s
  end

  def players_in_order(first, second, third, fourth) do
    ~r/#{first.player_name}.*#{second.player_name}.*#{third.player_name}.*#{fourth.player_name}/s
  end

  def create_four_test_players() do
    player1 =
      create_test_player(%{
        player_name: "David not2 not3 not4 Duncan",
        total_rushing_yards: 70,
        longest_rush: "53",
        total_rushing_touchdowns: 25
      })

    player2 =
      create_test_player(%{
        player_name: "Albert not1 not3 not4 Alfredson",
        total_rushing_yards: 69,
        longest_rush: "55T",
        total_rushing_touchdowns: 75
      })

    player3 =
      create_test_player(%{
        player_name: "Bob not1 not2 not4 Bippo",
        total_rushing_yards: 60,
        longest_rush: "59",
        total_rushing_touchdowns: 49
      })

    player4 =
      create_test_player(%{
        player_name: "Calvin not1 not2 not3 Cornelius",
        total_rushing_yards: 65,
        longest_rush: "50T",
        total_rushing_touchdowns: 50
      })

    {player1, player2, player3, player4}
  end

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
