defmodule Smartmeter.Framing.P1 do
  @behaviour Nerves.UART.Framing
  import Logger

  @initial_state %{mode: :none, buffer: <<>>, checksum: <<>>}

  def init(_args) do
    {:ok, @initial_state}
  end

  # we are not writing data back, so just passthrough here
  def add_framing(data, state) when is_binary(data) do
    {:ok, data, state}
  end

  def frame_timeout(state) do
    {:ok, [], %{mode: :none, buffer: <<>>, checksum: <<>>}}
  end

  def remove_framing(data, state) do
    process_data(data, state)    
  end

  def flush(_direction, _state) do
    %{mode: :none, buffer: <<>>, checksum: <<>>} 
  end
  
  #ignore everything until we receive a / the beginning of a telegram then switch to telegram mode
  defp process_data(<<char::binary-size(1), rest::binary>>, %{mode: :none, buffer: buffer, checksum: _} = state) do
    case char do
      "/" -> process_data(rest, %{state | mode: :telegram, buffer: buffer <> char})
      _   -> process_data(rest, state)
    end
  end

  # in telegram mode store every char in the buffer until we get a ! then switch to checksum mode
  defp process_data(<<char::binary-size(1), rest::binary>>, %{mode: :telegram, buffer: buffer, checksum: _} = state) do
    case char do
      "!" -> process_data(rest, %{state | mode: :checksum, buffer: buffer <> char})
      _   -> process_data(rest, %{state | buffer: buffer <> char})
    end
  end

  # process checksum until we have 4 characters
  defp process_data(<<char::binary-size(1), rest::binary>>, %{mode: :checksum, buffer: _buffer, checksum: checksum} = state) do
    if byte_size(checksum) == 3 do 
      final_state = %{state | checksum: checksum <> char}
      info "valid? #{Smartmeter.Framing.P1Checksum.check(final_state.buffer, final_state.checksum)}"
      {:ok, [final_state.buffer], @initial_state}
    else
      process_data(rest, %{state | checksum: checksum <> char})
    end
  end

  # current buffer is empty, wait until we get a checksum or timeout
  defp process_data(<<>>, state) do
    {:in_frame, [], state}
  end
end