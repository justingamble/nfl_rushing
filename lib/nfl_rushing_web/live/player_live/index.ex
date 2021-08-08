defmodule NflRushingWeb.PlayerLive.Index do
  use NflRushingWeb, :live_view

  alias NflRushing.PlayerStats
  alias NflRushing.PlayerStats.Player


  @impl true
  def mount(params, _session, socket) do
    IO.puts("------------------ index.ex: mount() executing.  ---------------\n")
    IO.inspect(params, label: "index.mount().params is")
    socket = assign(socket, :parent_params, params)
    IO.inspect(socket, label: "index.mount() socket is")
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do

    IO.puts("------------------ index.ex: handle_params() ---------------\n")

    socket =
      socket
      |> apply_action(socket.assigns.live_action, params)
      |> assign(
        parent_params: params
      )

    IO.inspect(socket, label: "index.handle_params.  Socket is ")

    {:noreply, socket}
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

#  @impl true
#  def handle_event("delete", %{"id" => id}, socket) do
#    player = PlayerStats.get_player!(id)
#    {:ok, _} = PlayerStats.delete_player(player)
#
#    player_filter = socket.assigns.player_filter
#    sort_by = socket.assigns.sort_by
#    paginate_options = socket.assigns.options
#
#    players = list_players(player_filter, sort_by, paginate_options)
#
#    {:noreply, assign(socket, :players, players)}
#  end

end
