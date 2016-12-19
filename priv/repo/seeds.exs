# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Runeforge.Repo.insert!(%Runeforge.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

data = [
  # { name,                  hp, bloodied, ac, fort, ref, will, str, con, dex, int, wis, cha }
    { "Darella Dawnstriker", 32, 16,       12, 15,   11,  14,   10,  20,  8,   11,  10,  16  },
    { "Dorksoda",            28, 14,       18, 15,   11,  12,   20,  16,  8,   10,  11,  10  },
    { "Pebble",              40, 20,       16, 17,   11,  15,   20,  11,  10,  10,  16,  8   },
    { "Willy Nally",         22, 11,       14, 11,   14,  15,   10,  12,  10,  18,  16,  12  }
]

defmodule Seeds do
  # Start import
  def import_data(data) do
    import_characters(data)
  end

  def import_characters([]), do: nil
  def import_characters([char | tail]) do
    {name, hp, bloodied, ac, fort, ref, will, str, con, dex, int, wis, cha} = char
    %Runeforge.Character{
      name: name,
      hp: hp,
      bloodied: bloodied,
      ac: ac,
      fort: fort,
      ref: ref,
      will: will,

      str: str,
      con: con,
      dex: dex,
      int: int,
      wis: wis,
      cha: cha
    }
      |> Runeforge.Repo.insert!

    import_characters(tail)
  end
end

Seeds.import_data(data)
