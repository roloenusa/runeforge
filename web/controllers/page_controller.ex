defmodule Runeforge.PageController do
  use Runeforge.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
