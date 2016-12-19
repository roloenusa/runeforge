defmodule Runeforge.CharacterTest do
  use Runeforge.ModelCase

  alias Runeforge.Character

  @valid_attrs %{ac: 42, bloodied: 42, cha: 42, con: 42, dex: 42, fort: 42, hp: 42, int: 42, name: "some content", ref: 42, str: 42, will: 42, wis: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Character.changeset(%Character{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Character.changeset(%Character{}, @invalid_attrs)
    refute changeset.valid?
  end
end
