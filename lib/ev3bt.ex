defmodule EV3BT do
  alias EV3BT.DirectCommand
  alias EV3BT.ConnectionManager, as: CM

  @layer_0 0 # Just means "this brick"

  def connect() do
    CM.start()
  end

  def close() do
    CM.stop()
  end

  def send_string(s) when is_binary(s) do
    String.split(s)
    |> Enum.map(fn x -> "0x" <> x end)
    |> Enum.map(fn x -> Code.eval_string(x) |> elem(0) end)
    |> :erlang.list_to_binary()
    |> CM.send_command()
  end

  def decode_data(<< 0, 0, value_byte,
                     _    :: size(4),
                     meta :: size(4)-signed >>) do
    num_value_bits = 3 + meta * 2
    << value :: size(num_value_bits), _ :: bitstring >> = << value_byte >>
    value
  end

  def play_sound() do
    cmd = <<0x94, 0x01, 0x83, 0x32, 0x00, 0x00, 0x00, 0x83, 0xe8, 0x03,
            0x00, 0x00, 0x83, 0xf4, 0x01, 0x00, 0x00>>
    DirectCommand.encode(:cmd_no_reply, cmd)
    |> CM.send_command()
  end

  def spin_motors() do
    cmd = DirectCommand.Motors.output_step_speed(@layer_0, [:outB, :outC],
                                                 50, 0, 900, 180, :brake)
    DirectCommand.encode(:cmd_no_reply, cmd)
    |> CM.send_command()
  end

end
