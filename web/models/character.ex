# Created with command:
# ```
#   mix phoenix.gen.html Character characters name:string hp:integer bloodied:integer \
#     ac:integer fort:integer ref:integer will:integer str:integer con:integer \
#     dex:integer int:integer wis:integer cha:integer
# ```
# It additionally created:
#   * creating web/controllers/character_controller.ex
#   * creating web/templates/character/edit.html.eex
#   * creating web/templates/character/form.html.eex
#   * creating web/templates/character/index.html.eex
#   * creating web/templates/character/new.html.eex
#   * creating web/templates/character/show.html.eex
#   * creating web/views/character_view.ex
#   * creating test/controllers/character_controller_test.exs
#   * creating web/models/character.ex
#   * creating test/models/character_test.exs
#   * creating priv/repo/migrations/20161219034413_create_character.exs

defmodule Runeforge.Character do
  use Runeforge.Web, :model

  @derive {Poison.Encoder, only: [:name, :hp, :bloodied]}

  schema "characters" do
    field :name, :string
    field :hp, :integer
    field :bloodied, :integer

    field :ac, :integer
    field :fort, :integer
    field :ref, :integer
    field :will, :integer
    field :str, :integer
    field :con, :integer
    field :dex, :integer
    field :int, :integer
    field :wis, :integer
    field :cha, :integer

    field :owner, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :hp, :bloodied, :ac, :fort, :ref, :will, :str, :con, :dex, :int, :wis, :cha, :owner])
    |> validate_required([:name, :hp, :bloodied, :ac, :fort, :ref, :will, :str, :con, :dex, :int, :wis, :cha])
  end

  def get_by_owner(owner_id) do
    query = from c in Runeforge.Character,
          where: c.owner == ^owner_id,
          select: c

    Runeforge.Repo.all(query)
  end
end
