defmodule Runeforge.BoardServer do
  require Logger

  use GenServer

  alias Runeforge.Repo
  alias Runeforge.Character

  # Client API

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  # Server implementation

  def init([]) do
    elements = %{}
    {:ok, %{elements: elements}}
  end

  #####
  # Interface
  #####

  def get() do
    GenServer.call(:board_server, {:get})
  end

  def move(payload, player_id) do
    GenServer.call(:board_server, {:move, payload, player_id})
  end

  def spawn(character_id, owner_id) do
    GenServer.call(:board_server, {:spawn, character_id, owner_id})
  end

  #####
  # Gen Server Calls
  #####

  def handle_call({:get}, _from, state = %{elements: []}) do
    {:reply, {:ok, []}, state}
  end
  def handle_call({:get}, _from, state = %{elements: elements}) do
    {:reply, {:ok, elements}, state}
  end

  def handle_call({:move, %{id: id, pos: pos}, player_id}, _from, state = %{elements: elements}) do
    response = handle_update_position(elements, id, pos, player_id)
    state = case response do
      {:ok, elements} -> %{state | elements: elements}
      _ -> state
    end
    {:reply, response, state}
  end

  def handle_call({:spawn, character_id, owner_id}, _from, state = %{elements: elements}) do
    character = Repo.get!(Character, character_id)
    id = :crypto.hash(:sha, "#{character.name}-#{:rand.uniform()}") |> Base.encode32

    elements = Map.put(
      elements,
      id,
      %{character: character, pos: %{x: 0, y: 0}, owner: owner_id}
    )

    state = %{state | elements: elements}
    {:reply, {:ok, elements}, state}
  end

  #####
  # Private functions.
  #####

  @doc """
  Move the element with ID to the position indicated.
  """
  def handle_update_position(elements, id, pos, player_id) do
    element = elements[id]
    case can_update_position?(element, player_id) do
      :ok ->
        elements = Map.update!(elements, id, fn(e) -> %{e | pos: pos} end)
        {:ok, elements}
      reason -> {:error, reason}
    end
  end

  @doc """
  Check if the element exists, and belongs to the player.
  """
  def can_update_position?(nil, _), do: :not_found
  def can_update_position?(element, player_id) do
    case element.owner do
      ^player_id -> :ok
      _ -> :not_owner
    end
  end
end
