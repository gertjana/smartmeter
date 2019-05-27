defmodule Smartmeter.Repo.Migrations.CreateInformationTable do
  use Ecto.Migration

  def change do
    create table(:information) do
      add :key, :string
      add :value, :string

      timestamps()
    end
  end
end
