defmodule Runeforge.Repo.Migrations.AddCharacterOwnerTable do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add :owner,   :integer
    end
  end
end
