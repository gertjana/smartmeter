defmodule Smartmeter.Repo.Migrations.AddChannelToInformation do
  use Ecto.Migration

  def change do
	alter table(:information) do
	  add :channel, :integer, default: 0
	end
  end
end
