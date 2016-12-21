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

  def update(payload) do
    GenServer.call(:board_server, {:update, payload})
  end

  #####
  # Gen Server Calls
  #####

  def handle_call({:get}, _from, map = %{elements: []}) do
    {:reply, {:ok, []}, map}
  end
  def handle_call({:get}, _from, map = %{elements: elements}) do
    {:reply, {:ok, elements}, map}
  end

  def handle_call({:update, %{id: id, pos: pos}}, _from, map = %{elements: elements}) do
    {_prev, elements} = Map.get_and_update(elements, id, fn(element) ->
      cur = element
      {cur, %{element | pos: pos}}
    end)

    {:reply, {:ok, elements}, %{map | elements: elements}}
  end

  #####
  # Private functions.
  #####
end
