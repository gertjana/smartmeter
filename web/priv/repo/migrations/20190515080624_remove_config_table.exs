defmodule Smartmeter.Repo.Migrations.RemoveConfigTable do
  use Ecto.Migration

  def change do
    drop_if_exists table(:config)
  end
end
