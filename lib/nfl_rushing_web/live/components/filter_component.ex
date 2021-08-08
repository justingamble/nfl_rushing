defmodule NflRushingWeb.FilterComponent do
  use NflRushingWeb, :live_component

  def render(assigns) do
    ~L"""
      <form phx-submit="player-filter" class="flex-wrap form-filter my-2">
        <div class="bg-white flex items-center">

          <input type="text" name="player_name" value="<%= @player %>"
                 class="border-b-2 border-green-700 focus:outline-none focus:ring focus:ring-green-200 p-2"
                 placeholder="<%= if @player_filter != "" do @player_filter else "Player Name" end %>"
                 autofocus autocomplete="off"
                 <%= if @loading, do: "readonly" %>
          />

          <button type="submit" class="bg-green-600 hover:bg-green-700 focus:outline-none text-white rounded-md ml-2 p-3">
              <svg class="inline-flex w-5 h-5 text-gray-600 cursor-pointer" fill="none"
                stroke-linecap="round" stroke-linejoin="round" stroke-width="2" stroke="white" viewBox="0 0 24 24">
                <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0x">
                </path>
              </svg>
              Filter players
          </button>
        </div>
      </form>
    """
  end
end
