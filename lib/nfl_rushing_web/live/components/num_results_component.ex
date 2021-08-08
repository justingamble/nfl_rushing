defmodule NflRushingWeb.NumResultsComponent do
  use NflRushingWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="flex justify-between items-center my-4">
        <div class="count">
          <label class="results-text">Total number of results:</label>
          <label class="text-green-600 font-bold results-number"><%= @player_num_results %></label>
        </div>
      </div>
    """
  end
end
