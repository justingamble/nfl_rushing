defmodule NflRushingWeb.PlayerLive.Index do
  use NflRushingWeb, :live_view

  alias NflRushing.PlayerStats
#  alias NflRushing.PlayerStats.Player
  alias NflRushingWeb.Endpoint

  require Integer

  @download_results_topic "download_results"

  @impl true
  def mount(params, _session, socket) do
    IO.puts("------------------ index.ex: mount() ---------------\n")
    IO.puts("______________ mount: setting loading to FALSE \n")

    paginate = get_paginate_from_params(params)

    if connected?(socket) do
      Endpoint.subscribe(@download_results_topic)
    end

    socket =
      assign(socket,
        players: [],
        player_num_results: 0,
        player_filter: "",
        loading: false,
        sort_by_choices: sort_options(),
        sort_by: :player_name,
        per_page_choices: per_page_options(),
        paginate: paginate
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.puts("------------------ index.ex: handle_params() entered ---------------\n")

    paginate = get_paginate_from_params(params)

    player_filter = socket.assigns.player_filter
    sort_by = socket.assigns.sort_by

    players = list_players(player_filter, sort_by, paginate)
    player_num_results = count_results(player_filter)

    socket =
      socket
      |> apply_action(socket.assigns.live_action, params)
      |> assign(
        paginate: paginate,
        players: players,
        player_num_results: player_num_results
      )

    IO.puts("------------------ index.ex: handle_params() exited ---------------\n")

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "player-filter",
        %{"player_name" => player_filter},
        %{assigns: %{sort_by: sort_column, paginate: paginate}} = socket
      ) do
    paginate_from_page_one = %{paginate | page: 1}

    IO.puts(
      "**** filter component's handle_event 'player-filter' -> received player: #{
        inspect(player_filter)
      }, got sort column from socket: #{inspect(sort_column)}
        \n ____________ setting loading to TRUE __________ \n
      "
    )

    socket =
      socket
      |> assign_loading_and_trigger_filter_and_sort(
        player_filter,
        sort_column,
        paginate_from_page_one
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "sort-selected",
        %{"sort_by_form" => %{"sort_by" => sort_by}},
        %{assigns: %{player_filter: player_filter, paginate: paginate}} = socket
      ) do
    IO.puts(
      "**** handle_event 'sort' -> received sort_column: '#{inspect(sort_by)}', and got player from socket: #{
        inspect(player_filter)
      }
      \n ____________ #2 setting loading to TRUE __________ \n
      "
    )

    sort_column = String.to_atom(sort_by)

    socket =
      socket
      |> assign_loading_and_trigger_filter_and_sort(
        player_filter,
        sort_column,
        paginate
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "per-page-selected",
        %{"per_page_form" => %{"per_page" => per_page}},
        %{
          assigns: %{
            player_num_results: player_num_results,
            paginate: paginate
          }
        } = socket
      ) do
    IO.puts(
      "**** handle_event 'per-page-selected' -> received per_page: '#{inspect(per_page)}'\n"
    )

    per_page = String.to_integer(per_page)

    paginate =
      get_paginate_when_per_page_changes(
        %{page: paginate.page, per_page: per_page},
        player_num_results
      )

    {:noreply, socket |> navigate_to_url(paginate)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    player = PlayerStats.get_player!(id)
    {:ok, _} = PlayerStats.delete_player(player)

    player_filter = socket.assigns.player_filter
    sort_by = socket.assigns.sort_by
    paginate = socket.assigns.paginate

    players = list_players(player_filter, sort_by, paginate)

    {:noreply, assign(socket, :players, players)}
  end

  @impl true
  def handle_info(
        %{event: "players_downloaded"},
        %{assigns: %{paginate: paginate}} = socket
      ) do
    socket =
      socket
      |> clear_flash()
      |> put_flash(:info, "Player data downloaded successfully")
      |> navigate_to_url(paginate)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:run_player_search, player_filter, sort_column, paginate}, socket)
      when is_atom(sort_column) do
    IO.puts("______________ run_player_search _______ setting loading to FALSE \n")

    case list_players(player_filter, sort_column, paginate) do
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

  defp assign_loading_and_trigger_filter_and_sort(
         socket,
         player_filter,
         sort_by,
         paginate
       ) do
    send(self(), {:run_player_search, player_filter, sort_by, paginate})

    socket
    |> clear_flash()
    |> assign(
      players: [],
      player_num_results: 0,
      loading: true,
      player_filter: player_filter,
      sort_by: sort_by,
      paginate: paginate
    )
  end

  defp navigate_to_url(socket, %{page: page, per_page: per_page}) do
    push_patch(socket,
      to: Routes.live_path(socket, __MODULE__, page: page, per_page: per_page)
    )
  end

  def count_results(player_filter) do
    PlayerStats.count(player_name: String.trim(player_filter))
  end

  def list_players(player_filter, sort_by, paginate) do
    PlayerStats.list_players(
      player_name: String.trim(player_filter),
      sort_by: sort_by,
      paginate: paginate
    )
  end

  defp sort_options() do
    [
      "Player Name": "player_name",
      "Total Rushing Yards (Yds)": "total_rushing_yards",
      "Total Rushing Touchdowns (TD)": "total_rushing_touchdowns",
      "Longest Rush (Lng)": "longest_rush"
    ]
  end

  defp get_paginate_from_params(params) do
    page = String.to_integer(params["page"] || default_paginate_page())
    per_page = String.to_integer(params["per_page"] || default_paginate_per_page())

    %{page: page, per_page: per_page}
  end

  defp get_paginate_when_per_page_changes(%{page: page, per_page: per_page}, player_num_results)
       when is_integer(per_page) do
    max_pages = max_pagination_page(player_num_results, per_page)

    %{page: min(page, max_pages), per_page: per_page}
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

  defp default_paginate_page() do
    "1"
  end

  defp default_paginate_per_page() do
    "5"
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

  defp apply_action(socket, :index, _params) do
    apply_list_players(socket)
  end

  defp apply_action(socket, nil, _params) do
    apply_list_players(socket)
  end

  defp apply_list_players(socket) do
    socket
    |> assign(:page_title, "Listing Players")
    |> assign(:player, nil)
  end
end
