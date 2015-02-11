defmodule ConstantMacros do

 defmacro __using__(_opts) do
    quote do
      import ConstantMacros
    end
  end

  @doc "Define a constant."
  defmacro constant(name, value) do
    quote do
      defmacro unquote(name), do: unquote(value)
    end
  end

  @doc "Define a constant. An alias for `constant`."
  defmacro define(name, value) do
    quote do
      constant unquote(name), unquote(value)
    end
  end

end
