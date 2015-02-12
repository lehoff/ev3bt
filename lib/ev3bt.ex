defmodule EV3BT do
  use EV3BT.Constants
  use EV3BT.ParameterEncoding
  alias EV3BT.DirectCommand
  alias EV3BT.DirectReply

  @layer_0 0x00 # Just means "this brick"

  @outA 0b1
  @outB 0b10
  @outC 0b100
  @outD 0b1000

  def connect() do
    pid = :serial.start(speed: 57600, open: "/dev/tty.EV3-SerialPort")
    Agent.start(fn -> pid end, name: :serial_pid)
    :ok
  end

  def close() do
    Agent.get(:serial_pid, fn x -> x end)
    |> send({:close})
    Agent.stop(:serial_pid)
  end

  def send_string(s) when is_binary(s) do
    String.split(s)
    |> Enum.map(fn x -> "0x" <> x end)
    |> Enum.map(fn x -> Code.eval_string(x) |> elem(0) end)
    |> :erlang.list_to_binary()
    |> send_binary()
  end

  def send_binary(b) when is_binary(b) do
    Agent.get(:serial_pid, fn x -> x end)
    |> send({:send, b})
  end

  def receive_reply() do
    receive do
      {:data, reply} ->
        DirectReply.decode(reply)
    after
      1000 -> "Nothing received"
    end
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
    |> send_binary()
  end

  def spin_motors() do
    cmd = EV3BT.op_output_step_speed(@layer_0, [@outB, @outC],
                                     50, 0, 900, 180, :brake)
    DirectCommand.encode(:cmd_no_reply, cmd)
    |> send_binary()
  end

  @mode_color 2
  def read_color(port \\ 2) do
    cmd = << ByteCodes.input_device     :: size(8),
             lc(InputSubCodes.ready_si) :: binary,
             lc(@layer_0)               :: binary,
             lc(sensor_port(port))      :: binary,
             lc(0x00)                   :: binary, # DONT_CHANGE_TYPE
             lc(@mode_color)            :: binary,
             lc(1)                      :: binary, # 1 data set,
             0x60                       :: size(8) >> # GLOBAL_VAR_INDEX0
    DirectCommand.encode(:cmd_reply, cmd, alloc_global: 4)
    |> send_binary()

    %{reply_type: :direct_reply_ok, data: data} = receive_reply()
    decode_data(data)
  end

  def sensor_port(p) do
    p - 1
  end

  def outA(), do: @outA
  def outB(), do: @outB
  def outC(), do: @outC
  def outD(), do: @outD

  @doc """

  ## Example

      EV3BT.send_binary(
        EV3BT.DirectCommand.encode(
          :cmd_no_reply,
          EV3BT.op_output_step_speed(0, [EV3BT.outB, EV3BT.outC],
                                     50, 0, 900, 180, :brake)))

  """
  def op_output_step_speed(layer, motors, speed, step1, step2, step3, brake) do
    nos = Enum.sum(motors) # Equivalent to 'bitwise or' in this case
    brake_val = case brake do :brake -> 1; :no_brake -> 0 end
    << ByteCodes.output_step_speed,
       enc_constants([layer, nos, speed, step1, step2, step3, brake_val])
         :: binary >>
  end

  def enc_constants(cs) do
     for c <- cs, into: <<>>, do: lc(c)
  end

end
