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
    elements = Repo.all(Character)
      |> Enum.reduce(%{}, fn(character, acc) ->
          name = character.name
          id = :crypto.hash(:sha, name) |> Base.encode32
          Map.put(acc, id, %{character: character, pos: %{x: 0, y: 0}})
        end)
    {:ok, %{elements: elements}}
  end

  #####
  # Interface
  #####

  def get() do
    GenServer.call(:board_server, {:get})
  end

  def move(payload) do
    GenServer.call(:board_server, {:move, payload})
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

  def handle_call({:move, %{id: id, pos: pos}}, _from, state = %{elements: elements}) do

    response = handle_update_position(elements, id, pos)
    state = case response do
      :error -> state
      elements -> state = %{state | elements: elements}
    end

    payload = %{name: "System", message: "#{elements[id].character.name} moved to #{Poison.encode! pos}"}
    Runeforge.Endpoint.broadcast("lobby", "new_message", payload)

    {:reply, {:ok, elements}, state}
  end

  #####
  # Private functions.
  #####

  @doc """
  Move the element with ID to the position indicated.
  """
  def handle_update_position(elements, id, pos) do
    find_at(elements, pos)
      |> update_position(elements, id, pos)
  end

  @doc """
  Update the position of the elements or return error.
  """
  def update_position(element, _e, _id, _pos) when is_map(element), do: :error
  def update_position(:not_found, elements, id, pos) do
    {_prev, new_elements} = Map.get_and_update(elements, id, fn(element) ->
      new_element = move_to_tile(element, pos)
      {element, new_element}
    end)
    new_elements
  end

  @doc """
  Get the element at the position.
  """
  def find_at(elements, pos) do
    Enum.find(elements, :not_found, fn(element = {_id, %{pos: p}}) ->
      p == pos
    end)
  end

  @doc """
  Moves the element to the given position.
  """
  def move_to_tile(element, pos) do
    %{element | pos: pos}
  end
end
