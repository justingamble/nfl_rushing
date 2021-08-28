defmodule NflRushingWeb.PlayerLiveTestHelper do
  def player_path(%{page: page_number, per_page: per_page}) do
    "/players?" <> "page=#{page_number}&per_page=#{per_page}"
  end

  def player_row(player), do: "#player-#{player.id}"

  def player_index(player, index), do: "#player-#{player.id}-index-#{index}"

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
