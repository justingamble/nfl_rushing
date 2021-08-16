defmodule NflRushingWeb.PlayerLive.Index do
  use NflRushingWeb, :live_view

  alias NflRushing.PlayerStats
  alias NflRushing.PlayerStats.Player

  require Integer

  @impl true
  def mount(params, _session, socket) do
    IO.puts("------------------ index.ex: mount() ---------------\n")
    IO.puts("______________ mount: setting loading to FALSE \n")

    paginate_options = set_pagination_from(params)

    socket =
      assign(socket,
        players: [],
        player_num_results: 0,
        player_filter: "",
        loading: false,
        sort_by_choices: sort_options(),
        sort_by: :player_name,
        per_page_choices: per_page_options(),
        paginate_options: paginate_options
      )

    {:ok, socket, temporary_assigns: [players: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.puts("------------------ index.ex: handle_params() ---------------\n")

    paginate_options = set_pagination_from(params)

    player_filter = socket.assigns.player_filter
    sort_by = socket.assigns.sort_by

    players = list_players(player_filter, sort_by, paginate_options)
    player_num_results = count_results(player_filter)

    socket =
      socket
      |> apply_action(socket.assigns.live_action, params)
      |> assign(
        paginate_options: paginate_options,
        players: players,
        player_num_results: player_num_results
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "player-filter",
        %{"player_name" => player_filter},
        %{assigns: %{sort_by: sort_column, paginate_options: paginate_options}} = socket
      ) do
    paginate_from_page_one = %{paginate_options | page: 1}
    send(self(), {:run_player_search, player_filter, sort_column, paginate_from_page_one})

    IO.puts(
      "**** filter component's handle_event 'player-filter' -> received player: #{
        inspect(player_filter)
      }, got sort column from socket: #{inspect(sort_column)}
        \n ____________ setting loading to TRUE __________ \n
      "
    )

    socket =
      socket
      |> clear_flash()
      |> assign(
        players: [],
        player_num_results: 0,
        loading: true,
        player_filter: player_filter,
        paginate_options: paginate_from_page_one
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "sort-selected",
        %{"sort_by_form" => %{"sort_by" => sort_by}},
        %{assigns: %{player_filter: player_filter, paginate_options: paginate_options}} = socket
      ) do
    IO.puts(
      "**** handle_event 'sort' -> received sort_column: '#{inspect(sort_by)}', and got player from socket: #{
        inspect(player_filter)
      }
      \n ____________ #2 setting loading to TRUE __________ \n
      "
    )

    sort_column = String.to_atom(sort_by)
    send(self(), {:run_player_search, player_filter, sort_column, paginate_options})

    socket =
      socket
      |> clear_flash()
      |> assign(
        players: [],
        player_num_results: 0,
        loading: true,
        sort_by: sort_column
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "per-page-selected",
        %{"per_page_form" => %{"per_page" => per_page}},
        %{
          assigns: %{
            player_filter: player_filter,
            player_num_results: player_num_results,
            sort_by: sort_by,
            paginate_options: paginate_options
          }
        } = socket
      ) do
    IO.puts(
      "**** handle_event 'per-page-selected' -> received per_page: '#{inspect(per_page)}', and got player from socket: #{
        inspect(player_filter)
      }
      \n  ___________ #3 setting loading ot TRUE _______________\n"
    )

    per_page = String.to_integer(per_page)
    max_pages = max_pagination_page(player_num_results, per_page)
    page = min(paginate_options.page, max_pages)

    paginate_options = %{paginate_options | page: page, per_page: per_page}
    send(self(), {:run_player_search, player_filter, sort_by, paginate_options})

    socket =
      socket
      |> clear_flash()
      |> assign(
        players: [],
        player_num_results: 0,
        loading: true,
        paginate_options: paginate_options
      )
      |> push_patch(
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            page: page,
            per_page: per_page
          )
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    player = PlayerStats.get_player!(id)
    {:ok, _} = PlayerStats.delete_player(player)

    player_filter = socket.assigns.player_filter
    sort_by = socket.assigns.sort_by
    paginate_options = socket.assigns.options

    players = list_players(player_filter, sort_by, paginate_options)

    {:noreply, assign(socket, :players, players)}
  end

  @impl true
  def handle_info({:run_player_search, player_filter, sort_column, paginate_options}, socket)
      when is_atom(sort_column) do
    IO.puts("______________ run_player_search _______ setting loading to FALSE \n")

    case list_players(player_filter, sort_column, paginate_options) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No players matching \"#{player_filter}\"")
          |> assign(players: [], player_num_results: 0, loading: false)

        {:noreply, socket}

      players ->
        count = count_results(player_filter)
        socket = assign(socket, players: players, player_num_results: count, loading: false)
        {:noreply, socket}
    end
  end

  def count_results(player_filter) do
    PlayerStats.count(player_name: player_filter)
  end

  def list_players(player_filter, sort_by, paginate_options) do
    PlayerStats.list_players(
      player_name: player_filter,
      sort_by: sort_by,
      paginate: paginate_options
    )
  end

  defp set_pagination_from(params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")

    %{page: page, per_page: per_page}
  end

  defp sort_options() do
    [
      "Player Name": "player_name",
      "Total Rushing Yards (Yds)": "total_rushing_yards",
      "Total Rushing Touchdowns (TD)": "total_rushing_touchdowns",
      "Longest Rush (Lng)": "longest_rush"
    ]
  end

  defp per_page_options() do
    [
      "5": "5",
      "10": "10",
      "15": "15",
      "20": "20"
    ]
  end

  defp pagination_styling do
    " hover:bg-green-700 hover:text-white hover:font-bold rounded "
  end

  defp maybe_selected_pagination_number(selected, page_num) do
    if selected == page_num do
      "text-yellow-500 bg-green-600 font-bold "
    else
      ""
    end
  end

  defp maybe_selected_sort_column(selected, column_name) do
    if selected == column_name do
      "text-yellow-500 font-bold"
    else
      ""
    end
  end

  # When showing the table results, we want alternate rows to have a different
  # colour.  We are using this function to decide on a class attribute for each row,
  # so that we can use CSS to decorate the rows.
  defp odd_or_even(row_number) do
    case Integer.is_even(row_number) do
      true -> " bg-green-50 "
      false -> ""
    end
  end

  # When deciding pagination, this is used to give the display of range of
  # pages to offer the user.
  defp pagination_range(total_num_results, page_number, per_page) do
    max_pages = max_pagination_page(total_num_results, per_page)
    local_min = min(max_pages - 2, page_number - 2)
    local_max = min(max_pages, page_number + 2)
    IO.puts("pagination_range.  min=#{inspect(local_min)}, max=#{inspect(local_max)}")
    local_min..local_max
  end

  defp max_pagination_page(total_num_results, per_page) do
    ceil(total_num_results / per_page)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Player")
    |> assign(:player, PlayerStats.get_player!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Player")
    |> assign(:player, %Player{})
  end

  ##  NOTE: if you :index from router.ex, then you need to specify :index here
  #  defp apply_action(socket, :index, _params) do
  defp apply_action(socket, _index, _params) do
    socket
    |> assign(:page_title, "Listing Players")
    |> assign(:player, nil)
  end
end
