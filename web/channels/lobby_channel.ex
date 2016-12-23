defmodule Runeforge.LobbyChannel do
  require Logger
  use Phoenix.Channel

  def join("lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_message", payload, socket) do
    broadcast! socket, "new_message", payload

    {:ok, elements} = Runeforge.BoardServer.get()
    broadcast! socket, "board_state", %{elements: elements}

    {:noreply, socket}
  end

  def handle_in("move", payload, socket) do
    Logger.debug Poison.encode! payload

    {:ok, elements} = payload
      |> map_keys_to_atoms
      |> Runeforge.BoardServer.move

    {:noreply, socket}
  end


  def map_keys_to_atoms(map) do
    Logger.debug Poison.encode! map
    map = Enum.reduce(map, %{}, fn ({key, value}, acc) ->
      key = String.to_existing_atom(key)
      value = case value do
        value when is_map(value) -> map_keys_to_atoms(value)
        value -> value
      end
      Map.put_new(acc, key, value)
    end)
  end
end
