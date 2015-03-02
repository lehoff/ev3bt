defmodule EV3BT.DirectCommand.Motors do
  use EV3BT.Constants
  use EV3BT.ParameterEncoding
  use Bitwise

  @motors %{outA: 0b1,
            outB: 0b10,
            outC: 0b100,
            outD: 0b1000}

  @layer_doc "The brick to which the command will be sent. " <>
             "Should be 0 unless the command should go to a daisy chained brick."

  @motor_doc "is a list of output ports `[:outA | :outB | :outC | :outD]`"

  @brake_doc "is either `:brake` or `:coast`"

  @doc """
  Resets one or several motors

  ## Arguments

  * `layer` - #{@layer_doc}
  * `motors` - #{@motor_doc}

  """
  def output_reset(layer, motors) do
    nos = motor_list_to_nos(motors)
    << ByteCodes.output_reset, lc([layer, nos]) :: binary >>
  end

  @doc """
  Stops one or several motors

  ## Arguments

  * `layer` - #{@layer_doc}
  * `motors` - #{@motor_doc}
  * `brake` - #{@brake_doc}

  """
  def output_stop(layer, motors, brake) do
    nos = motor_list_to_nos(motors)
    brake_val = brake_atom_to_brake_int(brake)
    << ByteCodes.output_stop, lc([layer, nos, brake_val]) :: binary >>
  end

  @doc """
  Sets motor power

  ## Arguments

  * `layer` - #{@layer_doc}
  * `motors` - #{@motor_doc}
  * `power` - in the range `-100..100`

  """
  def output_power(layer, motors, power) do
    nos = motor_list_to_nos(motors)
    << ByteCodes.output_power, lc([layer, nos, power]) :: binary >>
  end

  @doc """
  Sets motor speed

  ## Arguments

  * `layer` - #{@layer_doc}
  * `motors` - #{@motor_doc}
  * `speed` - in the range `-100..100`

  """
  def output_speed(layer, motors, speed) do
    nos = motor_list_to_nos(motors)
    << ByteCodes.output_speed, lc([layer, nos, speed]) :: binary >>
  end

  @doc """
  Starts one or several motors

  ## Arguments

  * `layer` - #{@layer_doc}
  * `motors` - #{@motor_doc}

  """
  def output_start(layer, motors) do
    nos = motor_list_to_nos(motors)
    << ByteCodes.output_start, lc([layer, nos]) :: binary >>
  end

  @doc """
  Sets motor speed with three phases (ramp up, constant speed and ramp down)
  and brake mode

  ## Arguments

  * `layer` - #{@layer_doc}
  * `motors` - #{@motor_doc}
  * `speed` - in the range `-100..100`
  * `step1` - is the number of steps used to ramp up.
  * `step2` - is the number of steps used for constant speed.
  * `step3` - is the number of steps used to ramp down.
  * `brake` - #{@brake_doc}

  ## Example

      EV3BT.send_binary(
        EV3BT.DirectCommand.encode(
          :cmd_no_reply,
          EV3BT.output_step_speed(0, [:outB, :outC],
                                  50, 0, 900, 180, :brake)))

  """
  def output_step_speed(layer, motors, speed, step1, step2, step3, brake) do
    nos = motor_list_to_nos(motors)
    brake_val = brake_atom_to_brake_int(brake)
    << ByteCodes.output_step_speed,
       lc([layer, nos, speed, step1, step2, step3, brake_val]) :: binary >>
  end

  #
  # Helper functions
  #

  def motor_list_to_nos(motors) do
    Enum.reduce(motors, 0, fn (m, acc) -> acc ||| @motors[m] end)
  end

  def brake_atom_to_brake_int(brake) do
    case brake do
      :coast -> 0
      :brake -> 1
    end
  end


end
