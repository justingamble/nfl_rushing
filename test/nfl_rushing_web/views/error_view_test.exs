defmodule NflRushingWeb.ErrorViewTest do
  use NflRushingWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View
  use Plug.Test

  # Credit to https://www.munich-made.com/2020/03/20200304220507-testing-custom-errorview-in-phoenix/
  # for the idea to create this setup() method, to setup a 'conn'
  setup do
    conn =
      conn(:get, "/something")
      |> Plug.Conn.put_private(:phoenix_endpoint, NflRushingWeb.Endpoint)

    {:ok, conn: conn}
  end

  test "renders 404.html", %{conn: conn} do
    result = render_to_string(NflRushingWeb.ErrorView, "404.html", conn: conn)
    assert result =~ ~r/Are you looking for the\s*.*href=\"\/players\".*Players statistics page/i
  end

  test "renders 500.html" do
    assert render_to_string(NflRushingWeb.ErrorView, "500.html", []) == "Internal Server Error"
  end
end
