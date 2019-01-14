defmodule Smartmeter.Config do
  use Ecto.Schema
  import Ecto.Changeset
  import Logger

  #TODO make it load the config only once from the db

  schema "config" do
    field :key, :string
    field :value, :string

    timestamps()
  end

  def typeof(self) do
    cond do
      is_float(self)    -> "float"
      is_number(self)   -> "number"
      is_atom(self)     -> "atom"
      is_boolean(self)  -> "boolean"
      is_binary(self)   -> "binary"
      is_function(self) -> "function"
      is_list(self)     -> "list"
      is_tuple(self)    -> "tuple"
    end    
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end

  def put(key, value) when is_atom(key) do
    debug "updating config: #{key} with #{value}, #{typeof(value)}"
    Smartmeter.Config 
      |> Smartmeter.Repo.get_by(key: Atom.to_string(key))
      |> changeset(%{value: value})
      |> Smartmeter.Repo.update
  end

  defp to_boolean(val) do
    case val do
      "true" -> true
      "false" -> false
      _ -> nil 
    end
  end

  defp get(key) when is_atom(key) do
    config = Smartmeter.Config |> Smartmeter.Repo.get_by(key: Atom.to_string(key))
    case  config do
      nil -> nil
      c   -> c.value 
    end
  end

  def get(key, :string),  do: get(key)
  def get(key, :integer), do: get(key) |> String.to_integer()
  def get(key, :float),   do: get(key) |> String.to_float()
  def get(key, :boolean), do: get(key) |> to_boolean()
  def get(key, :atom),    do: get(key) |> String.to_atom()
end
