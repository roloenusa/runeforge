defmodule Runeforge.Auth do
  require Logger

  import Plug.Conn
  import Phoenix.Controller

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def login(conn, player) do
      conn
      |> assign(:current_player, player)
      |> put_session(:player_id, player.id)
      |> configure_session(renew: true)
  end

  def call(conn, repo) do
    player_id = get_session(conn, :player_id)

    if player = player_id && repo.get(Runeforge.Player, player_id) do
        put_current_user(conn, player)
    else
        assign(conn, :current_player, nil)
    end
  end

  defp put_current_user(conn, player) do
      token = Phoenix.Token.sign(conn, "player socket", player.id)

      conn
      |> assign(:current_player, player)
      |> assign(:player_token, token)
  end
end
