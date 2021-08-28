defmodule NflRushing.PlayerStats do
  @moduledoc """
  The PlayerStats context.
  """

  import Ecto.Query, warn: false
  alias NflRushing.Repo
  alias NflRushing.PlayerStats.Player

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

  # Downloads the player data to the user.  The data is filtered & sorted according to the criteria.
  #
  # @params
  #    criteria = a list of filter criteria, applied to the database query to extract players
  #    callback = a function that takes one parameter (a database stream), and sends the data
  #               over the connection to the user.
  #
  # Credit to: https://medium.com/@feymartynov/streaming-csv-report-in-phoenix-4503b065bf4a
  # for this idea of streaming the results through CSV, while keeping a separation of concerns.
  def write_csv_download_file_from_player_query_stream(criteria, callback) do
    column_order = Player.get_ordered_list_of_short_headers()

    NflRushing.Repo.transaction(fn ->
      player_stream =
        criteria
        |> build_player_query
        # max_rows: how many rows to return in each batch?  Default=500
        |> NflRushing.Repo.stream(max_rows: 50)
        |> Stream.map(&Map.from_struct(&1))
        |> Stream.map(&Map.drop(&1, [:__meta__, :id, :inserted_at, :updated_at]))
        |> Stream.map(&Player.convert_map_keys_to_short_versions/1)
        |> CSV.Encoding.Encoder.encode(headers: column_order)

      callback.(player_stream)
    end)
  end

  # Returns a list of all players, that match all the specified criteria.
  # @params
  #    criteria = a list of filter criteria, applied to the database query to extract players
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
    #    :timer.sleep(2000)      ## Useful for testing load icon

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
          # 'longest_rush' contains a string of characters: optional negative sign, digits, optionally followed by 'T'.
          # First we sort by the numeric value, then sort the rows with "T" to be after the "non-T" rows,
          # and finally sort by the player name.
          from a in query,
            order_by: [asc: fragment("CAST(substring(?, '(-\\?[0-9]+)') AS integer)", a.longest_rush),
                      asc: fragment("CASE (longest_rush LIKE '%T')
                                       WHEN false THEN 0
                                       WHEN true THEN 1
                                     END"),
                      asc: a.player_name]

        {:sort_by, column}, query ->
          # The 'second_sort_by' guarantees an ordering, if the 'sort_by' field has the same value for different
          # records.  By using 'second_sort_by' we know that the downloaded file and the web display orderings
          # will match.
          second_sort_by =
            case column do
              :player_name -> :id
              _ -> :player_name
            end

          from a in query, order_by: [asc: ^column, asc: ^second_sort_by]
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
