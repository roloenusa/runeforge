defmodule Runeforge.CharacterControllerTest do
  use Runeforge.ConnCase

  alias Runeforge.Character
  @valid_attrs %{ac: 42, bloodied: 42, cha: 42, con: 42, dex: 42, fort: 42, hp: 42, int: 42, name: "some content", ref: 42, str: 42, will: 42, wis: 42}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, character_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing characters"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, character_path(conn, :new)
    assert html_response(conn, 200) =~ "New character"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, character_path(conn, :create), character: @valid_attrs
    assert redirected_to(conn) == character_path(conn, :index)
    assert Repo.get_by(Character, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, character_path(conn, :create), character: @invalid_attrs
    assert html_response(conn, 200) =~ "New character"
  end

  test "shows chosen resource", %{conn: conn} do
    character = Repo.insert! %Character{}
    conn = get conn, character_path(conn, :show, character)
    assert html_response(conn, 200) =~ "Show character"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, character_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    character = Repo.insert! %Character{}
    conn = get conn, character_path(conn, :edit, character)
    assert html_response(conn, 200) =~ "Edit character"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    character = Repo.insert! %Character{}
    conn = put conn, character_path(conn, :update, character), character: @valid_attrs
    assert redirected_to(conn) == character_path(conn, :show, character)
    assert Repo.get_by(Character, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    character = Repo.insert! %Character{}
    conn = put conn, character_path(conn, :update, character), character: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit character"
  end

  test "deletes chosen resource", %{conn: conn} do
    character = Repo.insert! %Character{}
    conn = delete conn, character_path(conn, :delete, character)
    assert redirected_to(conn) == character_path(conn, :index)
    refute Repo.get(Character, character.id)
  end
end
