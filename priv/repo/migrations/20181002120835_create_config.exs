defmodule Smartmeter.Repo.Migrations.CreateConfig do
  use Ecto.Migration

  def change do
    create table(:config) do
      add :key, :string
      add :value, :string

      timestamps()
    end

  end
end
