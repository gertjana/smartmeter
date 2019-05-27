defmodule Smartmeter.Framing.P1Checksum do

  @doc """
    CRC is a CRC16 value calculated over the preceding characters in the data message (from
    “/” to “!” using the polynomial: x16+x15+x2+1). CRC16 uses no XOR in, no XOR out and is
    computed with least significant bit first. The value is represented as 4 hexadecimal characters (MSB first).
  """
  @spec check(bitstring(), bitstring())::boolean()
  def check(data, checksum), do: checksum == calculate_checksum(data)

  defp calculate_checksum(data) do
    algo = %{
      width: 16,
      poly: 0xA001,
      init: 0x00,
      refin: false,
      refout: false,
      xorout: 0x00
    }
    CRC.crc(algo, data) |> Hexate.encode
  end
end
