defmodule Smartmeter.Information do
  use Ecto.Schema
  import Ecto.Changeset
  import Logger

  #TODO make it load the config only once from the db

  schema "information" do
    field :key, :string
    field :value, :string

    timestamps()
  end
  
  @doc false
  def changeset(information, attrs) do
    information
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end
  
  def put(key, value) do  
    debug "updating smartmeter information: #{key} with #{value}"
    case Smartmeter.Information |> Smartmeter.Repo.get_by(key: key) do
      nil -> Smartmeter.Repo.insert(%Smartmeter.Information{key: key, value: value})
      info -> info |> changeset(%{value: value}) |> Smartmeter.Repo.update
    end
  end

  def get(key) do
    Smartmeter.Information |> Smartmeter.Repo.get(key: key)
  end

  def getAll() do
    Smartmeter.Information |> Smartmeter.Repo.all
  end
end