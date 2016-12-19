defmodule Runeforge.LobbyChannel do
  use Phoenix.Channel

  def join("lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_message", payload, socket) do
    broadcast! socket, "new_message", payload
    {:noreply, socket}
  end

  def handle_in("characters", payload, socket) do
    {:ok, characters} = Runeforge.BoardServer.get()
    broadcast! socket, "new_message", characters
    {:noreply, socket}
  end
end
