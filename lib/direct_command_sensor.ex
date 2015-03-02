defmodule EV3BT.DirectCommand.Sensor do
  use EV3BT.Constants
  use EV3BT.ParameterEncoding

  @ports %{in1: 0,
           in2: 1,
           in3: 2,
           in4: 3}

  @layer_doc "The brick to which the command will be sent. " <>
             "Should be 0 unless the command should go to a daisy chained brick."

  @port_doc "The port to which the sensor is attached: " <>
            "`:in1 | :in2 | :in3 | :in4`"

  @mode_doc "The mode in which the sensor should be read: `0..`"


  @doc """


  ## Arguments

  * `layer` - #{@layer_doc}
  * `port` - #{@port_doc}
  * `mode` - #{@mode_doc}

  """
  def input_read_si(layer, port, mode) do
    << ByteCodes.input_device,
       lc([InputSubCodes.ready_si,
           layer,
           port_atom_to_int(port),
           0x00, # DONT_CHANGE_TYPE
           mode,
           1]) :: binary, # means 1 data set, matlab uses 0 however...
       0x60 >> # GLOBAL_VAR_INDEX0 ? Perhaps the address to previous allocation
  end

  #
  # Helper functions
  #

  def port_atom_to_int(port) do
    unless Enum.member?(Map.keys(@ports), port), do: raise "Invalid port"
    @ports[port]
  end

end
