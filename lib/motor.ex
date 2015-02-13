defmodule EV3BT.Motor do
  alias EV3BT.DirectCommand
  alias EV3BT.ConnectionManager, as: CM

  @layer_0 0  # Just means "this brick"

  @ports_doc "a port or a list of ports `:outA | :outB | :outC | :outD`"

  @doc """
  Sets speeds and starts motors

  * `ports` - #{@ports_doc}
  * `speed` - in the range `-100..100`

  """
  def forward(ports, speed) do
    change_speed(ports, speed)
    start(ports)
  end

  @doc """
  Resets one or several motors

  ## Arguments

  * `ports` - #{@ports_doc}

  """
  def reset(ports) do
    unless is_list(ports), do: ports = [ports]
    DirectCommand.Motors.output_reset(@layer_0, ports)
    |> CM.direct_command_no_reply()
  end

  @doc """
  Stops one or several motors

  ## Arguments

  * `ports` - #{@ports_doc}
  * `brake_mode` - either `:brake` or `:coast`

  """
  def stop(ports, brake_mode \\ :coast) do
    unless is_list(ports), do: ports = [ports]
    DirectCommand.Motors.output_stop(@layer_0, ports, brake_mode)
    |> CM.direct_command_no_reply()
  end

  @doc """
  Starts one or several motors

  ## Arguments

  * `ports` - #{@ports_doc}

  """
  def start(ports) do
    unless is_list(ports), do: ports = [ports]
    DirectCommand.Motors.output_start(@layer_0, ports)
    |> CM.direct_command_no_reply()
  end

  @doc """
  Changes speed

  ## Arguments

  * `ports` - #{@ports_doc}
  * `speed` - in the range `-100..100`

  """
  # TODO: Make it possible to output power instead of speed if desired
  def change_speed(ports, speed) do
    unless is_list(ports), do: ports = [ports]
    DirectCommand.Motors.output_speed(@layer_0, ports, speed)
    |> CM.direct_command_no_reply()
  end

end
