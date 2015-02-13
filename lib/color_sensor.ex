defmodule EV3BT.ColorSensor do
  use EV3BT.Constants
  use EV3BT.ParameterEncoding
  alias EV3BT.DirectCommand.Sensor
  alias EV3BT.ConnectionManager, as: CM

  @layer_0 0  # Just means "this brick"

  @device_type 29

  @modes %{reflect:     0,
           ambient:     1,
           color:       2,
           reflect_raw: 3,
           rgb:         4,
           calibration: 5}

  # Values for mode :color
  @colors %{0 => :nothing,
            1 => :black,
            2 => :blue,
            3 => :green,
            4 => :yellow,
            5 => :red,
            6 => :white,
            7 => :brown}

  @port_doc "The port to which the color sensor is attached " <>
            "`:in1 | :in2 | :in3 | :in4`"

  @doc """
  Reads the color

  ## Values

  * `:nothing`
  * `:black`
  * `:blue`
  * `:green`
  * `:yellow`
  * `:red`
  * `:white`
  * `:brown`

  ## Arguments

  * `port` - #{@port_doc}

  """
  def get_color(port) do
    Sensor.input_read_si(@layer_0, port, @modes[:color])
    |> CM.direct_command_sync(alloc_global: 4)
    |> (fn %{reply_type: :direct_reply_ok, data: data} ->
          data
        end).()
    |> EV3BT.decode_data()
    |> color_from_integer()
  end

  @doc """
  Reads the reflect value

  ## Values

  * `0..100`

  ## Arguments

  * `port` - #{@port_doc}

  """
  def get_reflect(port) do
    Sensor.input_read_si(@layer_0, port, @modes[:reflect])
    |> CM.direct_command_sync(alloc_global: 4)
    |> (fn %{reply_type: :direct_reply_ok, data: data} ->
          data
        end).()
    |> EV3BT.decode_data()
  end

  def get_reflect_async(port) do
    Sensor.input_read_si(@layer_0, port, @modes[:reflect])
    |> CM.direct_command_async(alloc_global: 4)
  end

  def decode_async_reply_reflect(%{reply_type: :direct_reply_ok, data: data}) do
    EV3BT.decode_data(data)
  end

  #
  # Helper functions
  #

  def color_from_integer(i) do
    @colors[i]
  end

end
