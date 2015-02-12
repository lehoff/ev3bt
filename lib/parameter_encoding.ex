defmodule EV3BT.ParameterEncoding do
  use EV3BT.Constants

  defmacro __using__(_opts) do
    quote do
      import EV3BT.ParameterEncoding
    end
  end

  @short_format 0
  @long_format 1

  @constant 0
  @constant_value 0

  @pos 0
  @neg 1

  def lc(xs) when is_list(xs),    do: (for x <- xs, into: <<>>, do: lc(x))

  def lc(x) when abs(x) < 32,     do: lc0(x)
  def lc(x) when abs(x) < 128,    do: lc1(x)
  def lc(x) when abs(x) < 32768,  do: lc2(x)
  def lc(x),                      do: lc4(x)

  def lc0(x) do
    {sign, v} = sign_value x
    << @short_format         :: size(1),
       @constant             :: size(1),
       sign                  :: size(1),
       v                     :: size(5) >>
  end

  def lc1(x) do
    << @long_format          :: size(1),
       @constant             :: size(1),
       @constant_value       :: size(1),
       0                     :: size(2),
       FollowType.one_byte   :: size(3),
       x                     :: size(8) >>
  end

  def lc2(x) do
    << @long_format          :: size(1),
       @constant             :: size(1),
       @constant_value       :: size(1),
       0                     :: size(2),
       FollowType.two_bytes  :: size(3),
       x                     :: size(16)-little >>
  end

  def lc4(x) do
    << @long_format          :: size(1),
       @constant             :: size(1),
       @constant_value       :: size(1),
       0                     :: size(2),
       FollowType.four_bytes :: size(3),
       x                     :: size(32)-little >>
  end

  #
  # Helper functions
  #

  defp sign_value(x) when x<0 do
    {@neg, -x}
  end

  defp sign_value(x) do
    {@pos, x}
  end

end
