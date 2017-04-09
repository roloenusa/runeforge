defmodule Runeforge.LobbyController do
  require Logger

  use Runeforge.Web, :controller

  import Runeforge.PlayerState

  def index(conn, _params) do

    player = get_session(conn, :player)
    {:ok, players} = Runeforge.PlayerServer.get_all()
    render(conn, "index.html", players: players, player: player)
  end

  def join(conn, %{"player" => %{"name" => name}} = params) do
    p = player_state(name: name)
    :ok = Runeforge.PlayerServer.join(p)
    conn = put_session(conn, :player, p)
    redirect(conn, to: lobby_path(conn, :index))
  end
end
