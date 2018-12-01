defmodule Smartmeter.Information do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  import Logger
  
  schema "information" do
    field :key, :string
    field :channel, :integer
    field :value, :string

    timestamps()
  end
  
  @doc false
  def changeset(information, attrs) do
    information
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end
  
  def put(key, value, channel \\ 0) do  
    debug "updating smartmeter information: #{key} with #{value}"
    case Smartmeter.Information |> Smartmeter.Repo.get_by([key: key, channel: channel]) do
      nil -> Smartmeter.Repo.insert(%Smartmeter.Information{key: key, value: value, channel: channel})
      info -> info |> changeset(%{value: value, channel: channel}) |> Smartmeter.Repo.update
    end
  end

  def get(key) do
    Smartmeter.Information |> Smartmeter.Repo.get(key: key)
  end

  def get_channels do
    Smartmeter.Repo.all(
      from i in Smartmeter.Information, where: i.channel != 0, order_by: i.channel) 
    |> Enum.group_by(fn x -> x.channel end)
  end

  def get_from_channel(channel) do
    Smartmeter.Repo.all(from i in Smartmeter.Information, where: i.channel == ^channel) 
  end

  def get_all() do
    Smartmeter.Repo.all(from i in Smartmeter.Information, order_by: i.channel)
  end
end