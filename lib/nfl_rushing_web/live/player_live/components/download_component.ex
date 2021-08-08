defmodule NflRushingWeb.PlayerLive.DownloadComponent do
  use NflRushingWeb, :live_component

#  alias NflRushingWeb.Api.DownloadController

  @impl true
  def render(assigns) do
    ~L"""
      <div class="w-1/2">
        <form phx-target="<%= @myself %>" phx-submit="player-download" class="form-download">
          <button type="submit"
                  class="bg-yellow-500 hover:bg-yellow-600 focus:outline-none
                         text-black font-semibold rounded-md mb-6 p-3 min-w-max
                         w-full">
            Download players
          </button>
        </form>
      </div>
    """
  end

  @impl true
  def handle_event(
        "player-download",
        _,
        %{
          assigns: %{
            player_filter: player_filter,
            sort_by: sort_by,
          }
        } = socket
      ) do
    IO.puts("**** handle_event 'player-download' pressed *****")
    #    {:noreply, redirect(socket, to: "/api/download")}

    # Consider having a redirect from cotnroller to here, so indicate when the file download has finished?
    {:noreply,
     socket |> redirect(to: "/api/download?sort_by=#{sort_by}&player_filter=#{player_filter}")}

    ###    {:noreply, redirect(socket, to: "/api/download?sort_by=player_name&player_filter=joe&return_to=" <> Routes.live_path(socket, __MODULE__))}
    #    {:noreply, redirect(socket, external: "https://localhost:4000/api/download?sort_by=Player_Name")}
    #    redirect(conn, external: "https://elixir-lang.org/")

    # DownloadController.index

    ##    path = Application.app_dir(:nfl_rushing, "priv/sample_download.csv")
    ##    send_download(conn, {:file, path})

    #    per_page = String.to_integer(per_page)
    #    max_pages = max_pagination_page(player_num_results, per_page)
    #    page = min(paginate_options.page, max_pages)
    #
    #    paginate_options = %{paginate_options | page: page, per_page: per_page}
    #    send(self(), {:run_player_search, player_filter, sort_by, paginate_options})
    #
    #    socket =
    #      socket
    #      |> clear_flash()
    #      |> assign(
    #        players: [],
    #        player_num_results: 0,
    #        loading: true,
    #        options: paginate_options
    #      )
    #      |> push_patch(
    #        to:
    #          Routes.live_path(
    #            socket,
    #            __MODULE__,
    #            page: page,
    #            per_page: per_page
    #          )
    #      )
    #
    #    {:noreply, socket}
  end

end
