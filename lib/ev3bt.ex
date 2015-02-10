defmodule EV3BT do

  @short_format 0
  @long_format 1
  @constant 0
  @constant_value 0
  @pos 0
  @neg 1
  @one_byte_follows 0b001
  @two_bytes_follows 0b010
  @four_bytes_follows 0b011
  @no_var_alloc 0
  @dc_reply 0
  @dc_noreply 0x80
  @cmd_types %{:cmd_reply    => @dc_reply,
               :cmd_no_reply => @dc_noreply}
  def outA(), do: 0b1
  def outB(), do: 0b10
  def outC(), do: 0b100
  def outD(), do: 0b1000    


  @doc ~S"""  
  Adds size, message counter and message type to a command or a bundled group of commands.

  ## Examples
     
      iex>  EV3BT.op_output_step_speed(0, [EV3BT.outA, EV3BT.outB], 50, 0, 900, 180, :cmd_reply)   
      <<174, 0, 3, 129, 50, 0, 130, 132, 3, 130, 180, 0, 1>>

      iex> EV3BT.op_output_step_speed(0, [EV3BT.outB, EV3BT.outC], 50, 0, 900, 180, :true) |> EV3BT.direct_command_encode(13, :cmd_no_reply) |> Hexate.encode
      "12000d00800000ae000681320082840382b40001"
  """   
  def direct_command_encode(commands, msg_counter, cmd_type) do
    cmd_size = byte_size commands
    << cmd_size + 5         :: size(16)-little,
       msg_counter          :: size(16)-little,
       @cmd_types[cmd_type] :: size(8),
       @no_var_alloc        :: size(16),
       commands             :: binary >>
  end
  
    
  def op_output_step_speed(layer, motors, speed, step1, step2, step3, brake) do
    nos = Enum.sum motors
    brake_val = if brake do 1 else 0 end
    << 0xaE >> <> enc_constants([layer,
                                 nos,
                                 speed,
                                 step1, step2, step3,
                                 brake_val])
  end

  def enc_constants(cs) do
    IO.iodata_to_binary( for c <- cs, do: lc(c) )  
  end
  
  
  def lc(x) when abs(x) < 32, do: lc0(x)
  def lc(x) when abs(x) < 128, do: lc1(x)
  def lc(x) when abs(x) < 32768, do: lc2(x)    
  def lc(x), do: lc4(x)
  
    
  def lc0(x) do
    {sign, v} = sign_value x
    << @short_format::1, @constant::1, sign::1, v::5 >>
  end

  
  def lc1(x) do
    << @long_format::1, @constant::1, @constant_value::1, 0::2,
       @one_byte_follows::3, x::8 >>
  end

  def lc2(x) do
    << @long_format::1, @constant::1, @constant_value::1, 0::2,
    @two_bytes_follows::3, x::little-size(16) >>
  end

  def lc4(x) do
    << @long_format::1, @constant::1, @constant_value::1, 0::2,
    @four_bytes_follows::3, x::little-size(32) >>
  end
  

  def sign_value(x) when x<0 do
    {@neg, -x}
  end

  def sign_value x do
    {@pos, x}
  end
  
  def reply_type_convert(:true), do: @dc_reply
  def reply_type_convert(:fales), do: @dc_noreply
  
end
