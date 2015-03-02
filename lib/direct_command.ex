defmodule EV3BT.DirectCommand do
  use EV3BT.Constants

  @type cmd_type :: :cmd_reply
                  | :cmd_no_reply

  @cmd_types %{:cmd_reply    => CommandType.direct_command,
               :cmd_no_reply => CommandType.direct_command_no_reply}

  @type alloc_local  :: 0..63
  @type alloc_global :: 0..1023

  @doc ~S"""
  Encodes a direct command with size, message counter, command type, variable
  allocation and the command / group of compound commands.

  # Arguments

  * `cmd_type` - `:cmd_reply` or `:cmd_no_reply`
  * `cmd` - A binary representing a single command or a compound of commands

  ## Options

  Three options can be given:

  * `:msg_counter` - A number which can be matched with the reply. Default: 0
  * `:alloc_local` - The number of bytes to allocate for local variables.
    Range: 0..63, Default: 0
  * `:alloc_global` - The number of bytes to allocate for global variables.
    Range: 0..1023, Default: 0

  ## Example

      iex> cmd = <<174, 0, 3, 129, 50, 0, 130, 132, 3, 130, 180, 0, 1>>
      iex> EV3BT.DirectCommand.encode(:cmd_reply, cmd) |> Hexate.encode
      "12000000000000ae000381320082840382b40001"

  """
  @encode_defaults [msg_counter: 0,
                    alloc_local:   0,
                    alloc_global:  0]

  @spec encode(cmd_type, cmd::binary, Keyword.t) :: binary

  def encode(cmd_type, cmd, opts \\ @encode_defaults) do
    options      = Keyword.merge(@encode_defaults, opts)
    msg_counter  = options[:msg_counter]
    alloc_local  = options[:alloc_local]
    alloc_global = options[:alloc_global]

    << byte_size(cmd) + 5     :: size(16)-little,       # Byte 0 & 1
       msg_counter            :: size(16)-little,       # Byte 2 & 3
       @cmd_types[cmd_type]   :: size(8),               # Byte 4
       rem(alloc_global, 256) :: size(8),               # Byte 5
       alloc_local            :: size(6),   # Bits 7-2 of byte 6
       div(alloc_global, 256) :: size(2),   # Bits 1-0 of byte 6
       cmd                    :: binary >>              # Byte 7 - n
  end

end
