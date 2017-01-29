defmodule Runeforge.PlayerServer do
  require Logger

  use GenServer

  import Runeforge.Player

  # Client API

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  # Server implementation

  def init([]) do
    {:ok, %{players: []}}
  end

  #####
  # Interface
  #####

  def join(player) do
    GenServer.call(:player_server, {:add, player})
  end

  def get_all() do
    GenServer.call(:player_server, {:get})
  end

  def leave(player) do
    GenServer.call(:player_server, {:leave, player})
  end

  #####
  # Gen Server Calls
  #####

  def handle_call({:add, player}, _from, state = %{players: players}) do
    players = [player | players]
    state = %{state | players: players}
    {:reply, :ok, state}
  end
  def handle_call({:get}, _from, state = %{players: players}) do
    {:reply, {:ok, players}, state}
  end
  def handle_call({:leave, player}, _from, state = %{players: players}) do
    players = List.delete(players, player)
    state = %{state | players: players}
    {:reply, :ok, state}
  end

  #####
  # Private functions.
  #####
end
