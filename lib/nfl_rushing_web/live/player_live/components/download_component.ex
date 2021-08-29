defmodule NflRushingWeb.PlayerLive.DownloadComponent do
  use NflRushingWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <div class="w-1/2 bg-yellow-500 hover:bg-yellow-600 focus:outline-none
                  text-black font-semibold rounded-md mb-6 p-3 min-w-max
                  ">
        <a href=<%= Routes.static_path(@socket, download_path(%{sort_by: @sort_by, player_filter: @player_filter})) %> id="download-link" target="_blank">
          <div class="text-center">
            Download players
          </div>
        </a>
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
            sort_by: sort_by
          }
        } = socket
      ) do
    IO.puts("**** handle_event 'player-download' pressed *****")

    children =
      {NflRushingWeb.Api.DownloadController,
       [player_filter: player_filter, sort_by: sort_by, socket: socket]}

    Supervisor.start_link([children], strategy: :one_for_one)
    :timer.sleep(5000)

    # TODO: consider having a pubsub message to indicate when the file download has finished?
    {:noreply,
     socket |> redirect(to: download_path(%{sort_by: sort_by, player_filter: player_filter}))}
  end

  defp download_path(%{sort_by: sort_by, player_filter: player_filter}) do
    "/api/download?sort_by=#{sort_by}&player_filter=#{player_filter}"
  end
end
