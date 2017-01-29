defmodule Runeforge.CharacterController do
  require Logger

  use Runeforge.Web, :controller

  alias Runeforge.Character

  def index(conn, _params) do
    player = get_session(conn, :player)
    player_id = player.id

    {:ok, owned_list} = Runeforge.BoardServer.get_owned(player.id)
    owned_list = Enum.reduce(owned_list, [],
      fn({_, %{character: %{id: id}}}, acc) -> [id | acc]
        (_, acc) -> acc
      end
    )

    IO.inspect "---------------------"
    IO.inspect owned_list

    characters = Repo.all(Character)
    |> Enum.reduce({[], []},
      fn(char, {owned, available}) ->
        case Enum.member?(owned_list, char.id) do
          true -> {[char | owned], available}
          _ -> {owned, [char | available]}
        end
      end
    )
    render(conn, "index.html", characters: characters, player: player)
  end

  def new(conn, _params) do
    changeset = Character.changeset(%Character{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"character" => character_params}) do
    changeset = Character.changeset(%Character{}, character_params)

    case Repo.insert(changeset) do
      {:ok, _character} ->
        conn
        |> put_flash(:info, "Character created successfully.")
        |> redirect(to: character_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    character = Repo.get!(Character, id)
    render(conn, "show.html", character: character)
  end

  def edit(conn, %{"id" => id}) do
    character = Repo.get!(Character, id)
    changeset = Character.changeset(character)
    render(conn, "edit.html", character: character, changeset: changeset)
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    character = Repo.get!(Character, id)
    changeset = Character.changeset(character, character_params)

    case Repo.update(changeset) do
      {:ok, character} ->
        conn
        |> put_flash(:info, "Character updated successfully.")
        |> redirect(to: character_path(conn, :show, character))
      {:error, changeset} ->
        render(conn, "edit.html", character: character, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    character = Repo.get!(Character, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(character)

    conn
    |> put_flash(:info, "Character deleted successfully.")
    |> redirect(to: character_path(conn, :index))
  end

  def spawn(conn, %{"character_id" => character_id}) do
    player = get_session(conn, :player)
    Runeforge.BoardServer.spawn(character_id, player.id)

    conn
    |> put_flash(:info, "Character spawned.")
    |> redirect(to: character_path(conn, :index))
  end
end
