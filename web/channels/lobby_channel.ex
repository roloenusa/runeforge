defmodule Runeforge.LobbyChannel do
  require Logger
  use Phoenix.Channel

  def join("lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_message", payload, socket) do
    broadcast! socket, "new_message", payload
    {:noreply, socket}
  end
  def handle_in("board", _payload, socket) do
    {:ok, elements} = Runeforge.BoardServer.get()
    broadcast! socket, "board_state", %{elements: elements}
    {:noreply, socket}
  end
  def handle_in("move", payload, socket) do
    player = socket.assigns[:current_player]
    player_id = case player do
      nil -> nil
      player -> player.id
    end

    response = payload
      |> map_keys_to_atoms
      |> Runeforge.BoardServer.move(player_id)

    case response do
      {:ok, elements} ->
        %{id: id, pos: pos} = payload
        |> map_keys_to_atoms

        p = %{name: "System", message: "Player: #{player.name} moved to #{Poison.encode! pos}"}
        Runeforge.Endpoint.broadcast("lobby", "new_message", p)
        Runeforge.Endpoint.broadcast("lobby", "board_state", %{elements: elements})
      {:error, :not_found} ->
        p = %{name: "System", message: "That element does not exist."}
        Runeforge.Endpoint.broadcast("lobby", "new_message", p)
      {:error, :not_owner} ->
        p = %{name: "System", message: "Player #{player.name} is not the onwer of that element."}
        Runeforge.Endpoint.broadcast("lobby", "new_message", p)
    end

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
