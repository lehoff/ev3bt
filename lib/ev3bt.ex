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
  @no_var_alloc << 0::16 >>
  @dc_reply 0
  @dc_noreply 0x80
  
  def outA(), do: 0b1
  def outB(), do: 0b10
  def outC(), do: 0b100
  def outD(), do: 0b1000    


  @doc ~S"""  
  Adds size, message counter and message type to a command or a bundled group of commands.

  ## Examples
     
      iex>  EV3BT.op_output_step_speed(0, [EV3BT.outA, EV3BT.outB], 50, 0, 900, 180, :true)   
      <<174, 0, 3, 129, 50, 0, 130, 132, 3, 130, 180, 0, 1>>

      iex> EV3BT.op_output_step_speed(0, [EV3BT.outB, EV3BT.outC], 50, 0, 900, 180, :true) |> EV3BT.direct_command_encode(13, :false) |> Hexate.encode
      "12000000000080AE000681320082840382B40001"

  """   
  def direct_command_encode(commands, msg_counter, reply_required) do
    type = if reply_required do
             << @dc_reply::8 >>
           else
             << @dc_noreply::8 >>
           end
    payload = IO.iodata_to_binary [ << msg_counter::little-size(16) >>,
                                    @no_var_alloc,
                                    type,
                                    commands ]
    size = byte_size payload
    << size::little-size(16) >> <> payload
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
  
  
  
end
