defmodule Runeforge.PlayerState do
  require Record
  Record.defrecord :player_state, name: nil, initiative: 0, actors: %{}

  @type player :: record(:player_state, name: String.t, initiative: integer, actors: %{})
  # expands to: "@type player :: {:user, String.t, integer}"

  def roll_initiative(record) do
    roll = :rand.uniform(20)
    player_state(record, initiative: roll)
  end

  def add_actor(player_state(actors: elm) = record, key) do
    elm = Map.put(elm, key, nil)
    record = player_state(record, actors: elm)
  end

  def remove_actor(player_state(actors: elm) = record, key) do
    elm = Map.delete(elm, key)
    record = player_state(record, actors: elm)
  end

  def owns?(player_state(actors: elm) = record, key), do: Map.has_key?(elm, key)
end
