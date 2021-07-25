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

  # Returns a list of all players, that match all the specified criteria.
  # @params
  #    criteria = a list of filter criteria.
  # By using a generic filter criteria list we are prepared to support
  # additional filter criteria, as needed.
  #
  # Example criteria:  [player_name: "joe"]
  # will find all records where player_name contains 'joe' as part/all of the name.
  def list_players(criteria) when is_list(criteria) do
    #:timer.sleep(3000)      ## Useful for testing load icon

    query = from(p in Player)

    IO.puts(
      "************** #{inspect(__MODULE__)}, list_players called: #{inspect(criteria)} *******\n"
    )

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
    |> Repo.all()
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
