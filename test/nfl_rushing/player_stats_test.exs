defmodule NflRushing.PlayerStatsTest do
  use NflRushing.DataCase

  alias NflRushing.PlayerStats

  describe "players" do
    alias NflRushing.PlayerStats.Player

    @valid_attrs %{
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

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PlayerStats.create_player()

      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert PlayerStats.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert PlayerStats.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      assert {:ok, %Player{} = player} = PlayerStats.create_player(@valid_attrs)
      assert player.longest_rush == "some longest_rush"
      assert player.player_name == "some player_name"
      assert player.player_position == "some player_position"
      assert player.rushing_attempts == 42
      assert player.rushing_attempts_per_game_avg == 120.5
      assert player.rushing_avg_yards_per_attempt == 120.5
      assert player.rushing_first_down_percentage == 120.5
      assert player.rushing_first_downs == 42
      assert player.rushing_forty_plus_yards_each == 42
      assert player.rushing_fumbles == 42
      assert player.rushing_twenty_plus_yards_each == 42
      assert player.rushing_yards_per_game == 120.5
      assert player.team_name == "some team_name"
      assert player.total_rushing_touchdowns == 42
      assert player.total_rushing_yards == 42
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PlayerStats.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, %Player{} = player} = PlayerStats.update_player(player, @update_attrs)
      assert player.longest_rush == "some updated longest_rush"
      assert player.player_name == "some updated player_name"
      assert player.player_position == "some updated player_position"
      assert player.rushing_attempts == 43
      assert player.rushing_attempts_per_game_avg == 456.7
      assert player.rushing_avg_yards_per_attempt == 456.7
      assert player.rushing_first_down_percentage == 456.7
      assert player.rushing_first_downs == 43
      assert player.rushing_forty_plus_yards_each == 43
      assert player.rushing_fumbles == 43
      assert player.rushing_twenty_plus_yards_each == 43
      assert player.rushing_yards_per_game == 456.7
      assert player.team_name == "some updated team_name"
      assert player.total_rushing_touchdowns == 43
      assert player.total_rushing_yards == 43
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = PlayerStats.update_player(player, @invalid_attrs)
      assert player == PlayerStats.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = PlayerStats.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> PlayerStats.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = PlayerStats.change_player(player)
    end
  end
end
