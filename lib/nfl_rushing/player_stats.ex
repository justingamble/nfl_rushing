defmodule NflRushing.PlayerStats do
  @moduledoc """
  The PlayerStats context.
  """

  import Ecto.Query, warn: false
  alias NflRushing.Repo

  alias NflRushing.PlayerStats.Player
  #  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
  end

  # Returns the number of database hits for the criteria.  Criteria is formatted
  # the same as list_players().
  def count(criteria) when is_list(criteria) do
    query = from p in Player, select: count(p.id)

    Enum.reduce(criteria, query, fn
      {:player_name, ""}, query ->
        query

      {:player_name, player_name}, query ->
        player_regex = "%" <> player_name <> "%"
        from a in query, where: like(a.player_name, ^player_regex)

      _, query ->
        query
    end)
    |> Repo.all()
    |> hd
  end

  def get_stats_headers() do
#    Player.get_stats_headers()
  end

  # Credit to: https://medium.com/@feymartynov/streaming-csv-report-in-phoenix-4503b065bf4a
  # for this idea of streaming the results through CSV, while keeping a separation of concerns.
  def write_csv_download_file_from_player_query_stream(criteria, callback) do
    # Ideas:
    # 1. Swap the map_keys with your custom_map_keys
    # 2. Convert map to list, sorter into your preferred order, and convert back to a map
    #        - Use Enum.sort/3
    #        - Have a map function of each column to its numeric position, and the
    #          sort mapper function can then just return which one is lower.
    # 3. Move this logic into player_stats.ex.  But the transaction need conn.  Use callback?
#    column_order = [
#      :player_name,
#      :team_name,
#      :player_position,
#      :rushing_attempts_per_game_avg,
#      :rushing_attempts,
#      :total_rushing_yards,
#      :rushing_avg_yards_per_attempt,
#      :rushing_yards_per_game,
#      :total_rushing_touchdowns,
#      :longest_rush,
#      :rushing_first_downs,
#      :rushing_first_down_percentage,
#      :rushing_twenty_plus_yards_each,
#      :rushing_forty_plus_yards_each,
#      :rushing_fumbles
#    ]
    column_order = Player.get_ordered_list_of_short_headers()

    NflRushing.Repo.transaction(fn ->
      player_stream =
        criteria
        |> build_player_query
        # max_rows: how many rows to return in each batch?  Default=500
        |> NflRushing.Repo.stream(max_rows: 50)
        |> Stream.map(fn x ->
          IO.puts("================== before from_struct.. #{inspect(x)}\n")
          x
        end)
        |> Stream.map(&Map.from_struct(&1))
        |> Stream.map(fn x ->
          IO.puts("================== after from_struct.. #{inspect(x)}\n")
          x
        end)
        |> Stream.map(&Map.drop(&1, [:__meta__, :id, :inserted_at, :updated_at]))
        |> Stream.map(fn x ->
          IO.puts("================== after dropping extra fields.. #{inspect(x)}\n")
          x
        end)
        |> Stream.map(&Player.convert_map_keys_to_short_versions/1)
#        |> Stream.map(&apply_desired_column_order(&1))
        #        |> Stream.map(&Enum.to_list(&1) |> Enum.sort( &order_columns(fn({key1, value1}, {key2, value2}) -> key1 < key2 end)
        |> CSV.Encoding.Encoder.encode(headers: column_order)
        #      |> CSV.Encoding.Encoder.encode(headers: header_string) <-- TODO: convert my map to one with header_string headers
        |> Stream.map(fn x ->
          IO.puts("================== after CSV.encode  #{inspect(x)}\n")
          x
        end)

      callback.(player_stream)
    end)
  end


#  defp apply_desired_column_order(player_map) when is_map(player_map) do
#    Enum.to_list(player_map)
#    |> IO.inspect(label: "apply_desired_column_order, player_map as list")
#    |> Enum.sort(&desired_column_order(&1, &2))
#    |> IO.inspect(label: "apply_desired_column_order, result")
#    |> Map.new
#  end

#  defp desired_column_order(column1, column2) do
#    IO.puts("desired_column_order.  received column1=#{inspect(column1)}, column2=#{inspect(column2)}")
#    column_score(column1) < column_score(column2)
#  end

#  defp column_score({column_name, _column_value} = _column) do
#    IO.puts("get_column_score. received #{inspect(column_name)}")
#
#    case column_name do
#      :player_name -> 1
#      :team_name -> 2
#      :player_position -> 3
#      :rushing_attempts_per_game_avg -> 4
#      :rushing_attempts -> 5
#      :total_rushing_yards -> 6
#      :rushing_avg_yards_per_attempt -> 7
#      :rushing_yards_per_game -> 8
#      :total_rushing_touchdowns -> 9
#      :longest_rush -> 10
#      :rushing_first_downs -> 11
#      :rushing_first_down_percentage -> 12
#      :rushing_twenty_plus_yards_each -> 13
#      :rushing_forty_plus_yards_each -> 14
#      :rushing_fumbles -> 15
#    end
#  end

  # Returns a list of all players, that match all the specified criteria.
  # @params
  #    criteria = a list of filter criteria.
  # By using a generic filter criteria list we are prepared to support
  # additional filter criteria, as needed.
  #
  # Example criteria:  [player_name: "joe"]
  # will find all records where player_name contains 'joe' as part/all of the name.
  def list_players(criteria) when is_list(criteria) do
    criteria
    |> build_player_query
    |> Repo.all()
  end

  # Returns a query that will filter/sort the players as requested, according to the criteria
  #
  # @params
  #    criteria = a list of filter criteria.
  # By using a generic filter criteria list we are prepared to support
  # additional filter criteria, as needed.
  #
  # Example criteria:  [player_name: "joe"]
  # will find all records where player_name contains 'joe' as part/all of the name.
  def build_player_query(criteria) when is_list(criteria) do
    # :timer.sleep(3000)      ## Useful for testing load icon

    query = from(p in Player)

    IO.puts(
      "******* #{inspect(__MODULE__)}, build_player_query(): , list_players called: #{
        inspect(criteria)
      } *****\n"
    )

    final_query =
      Enum.reduce(criteria, query, fn
        {:player_name, ""}, query ->
          query

        {:player_name, player_name}, query ->
          player_regex = "%" <> player_name <> "%"
          from a in query, where: like(a.player_name, ^player_regex)

        {:paginate, %{page: page, per_page: per_page}}, query ->
          from q in query,
            offset: ^((page - 1) * per_page),
            limit: ^per_page

        {:sort_by, :longest_rush}, query ->
          # longest_rush contains a string of characters: optional negative sign, digits, optionally followed by 'T'.
          # Ignore 'T' for sorting purposes.
          from a in query,
            order_by: fragment("cast(substring(?, '(-\\?[0-9]+)') as integer)", a.longest_rush)

        {:sort_by, column}, query ->
          from a in query, order_by: [asc: ^column]
          #      {:type, type}, query ->
          #        from q in query, where: q.type == ^type
          #
          #      {:prices, [""]}, query ->
          #        query
          #
          #      {:prices, prices}, query ->
          #        from q in query, where: q.price in ^prices
      end)

    final_query
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{data: %Player{}}

  """
  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end
end
