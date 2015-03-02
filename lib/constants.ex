defmodule EV3BT.Constants do
  use ConstantMacros
  use Bitwise

  @moduledoc """
  This module contains constants which are useful when creating direct commands.

  Let the constants be accessible in your module by specifying this:

      use EV3BT.Constants

  """

  defmacro __using__(_opts) do
    quote do
      require EV3BT.Constants.ParameterFormat
      alias EV3BT.Constants.ParameterFormat

      require EV3BT.Constants.ParameterType
      alias EV3BT.Constants.ParameterType

      require EV3BT.Constants.ShortSign
      alias EV3BT.Constants.ShortSign

      require EV3BT.Constants.ConstantParameterType
      alias EV3BT.Constants.ConstantParameterType

      require EV3BT.Constants.VariableScope
      alias EV3BT.Constants.VariableScope

      require EV3BT.Constants.VariableType
      alias EV3BT.Constants.VariableType

      require EV3BT.Constants.FollowType
      alias EV3BT.Constants.FollowType

      require EV3BT.Constants.ProgramSlots
      alias EV3BT.Constants.ProgramSlots

      require EV3BT.Constants.DaisyChainLayer
      alias EV3BT.Constants.DaisyChainLayer

      require EV3BT.Constants.CommandType
      alias EV3BT.Constants.CommandType

      require EV3BT.Constants.SystemCommand
      alias EV3BT.Constants.SystemCommand

      require EV3BT.Constants.ByteCodes
      alias EV3BT.Constants.ByteCodes

      require EV3BT.Constants.SoundSubCodes
      alias EV3BT.Constants.SoundSubCodes

      require EV3BT.Constants.InputSubCodes
      alias EV3BT.Constants.InputSubCodes

      require EV3BT.Constants.FileSubCodes
      alias EV3BT.Constants.FileSubCodes

      require EV3BT.Constants.MemorySubCodes
      alias EV3BT.Constants.MemorySubCodes
    end
  end

  # Source: https://github.com/jcnnghm/ruby-ev3/blob/master/lib/ev3/constants.rb

  defmodule ParameterFormat do
    define short, 0x00
    define long, 0x80
  end

  defmodule ParameterType do
    define constant, 0x00
    define variable, 0x40
  end

  defmodule ShortSign do
    define positive, 0x00
    define negative, 0x20
  end

  defmodule ConstantParameterType do
    define value, 0x00
    define label, 0x20
  end

  defmodule VariableScope do
    define local, 0x00
    define global, 0x20
  end

  defmodule VariableType do
    define value, 0x00
    define handle, 0x10
  end

  defmodule FollowType do
    define one_byte, 0x01
    define two_bytes, 0x02
    define four_bytes, 0x03
    define terminated_string, 0x00
    define terminated_string2, 0x04
  end

  defmodule ProgramSlots do
    # Program slot reserved for executing the user interface
    define gui, 0
    # Program slot used to execute user projects, apps and tools
    define user, 1
    # Program slot used for direct commands coming from c_com
    define cmd, 2
    # Program slot used for direct commands coming from c_ui
    define term, 3
    # Program slot used to run the debug ui
    define debug, 4
    # ONLY VALID IN opPROGRAM_STOP
    define current, -1
  end

  defmodule DaisyChainLayer do
    # The EV3
    define ev3, 0
    # First EV3 in the Daisychain
    define first, 1
    # Second EV3 in the Daisychain
    define second, 2
    # Third EV3 in the Daisychain
    define third, 3
  end

  defmodule CommandType do
    define without_reply, 0x80

    # Direct command
    define direct_command, 0x00
    define direct_command_no_reply, direct_command ||| without_reply
    # System command.
    define system_command, 0x01
    define system_command_no_reply, system_command ||| without_reply
    # Direct command reply.
    define direct_reply, 0x02
    # System command reply.
    define system_reply, 0x03
    # Direct reply with error.
    define direct_reply_with_error, 0x04
    # System reply with error.
    define system_reply_with_error, 0x05
  end

  defmodule SystemCommand do
    define none, 0x00
    define begin_download, 0x92
    define continue_download, 0x93
    define begin_upload, 0x94
    define continue_upload, 0x95
    define begin_get_file, 0x96
    define continue_get_file, 0x97
    define close_file_handle, 0x98
    define list_files, 0x99
    define continue_list_files, 0x9a
    define create_dir, 0x9b
    define delete_file, 0x9c
    define list_open_handles, 0x9d
    define write_mailbox, 0x9e
    define bluetooth_pin, 0x9f
    define enter_firmware_update, 0xa0
  end

  defmodule ByteCodes do
    # VM
    define program_stop, 0x02
    define program_start, 0x03
    # Move
    define init_bytes, 0x2F
    # VM
    define info, 0x7C
    define string, 0x7D
    define memory_write, 0x7E
    define memory_read, 0x7F
    # Sound
    define sound, 0x94
    define sound_test, 0x95
    define sound_ready, 0x96
    # Input
    define input_sample, 0x97
    define input_device_list, 0x98
    define input_device, 0x99
    define input_read, 0x9a
    define input_test, 0x9b
    define input_ready, 0x9c
    define input_read_si, 0x9d
    define input_read_ext, 0x9e
    define input_write, 0x9f
    # output
    define output_get_type, 0xa0
    define output_set_type, 0xa1
    define output_reset, 0xa2
    define output_stop, 0xA3
    define output_power, 0xA4
    define output_speed, 0xA5
    define output_start, 0xA6
    define output_polarity, 0xA7
    define output_read, 0xA8
    define output_test, 0xA9
    define output_ready, 0xAA
    define output_position, 0xAB
    define output_step_power, 0xAC
    define output_time_power, 0xAD
    define output_step_speed, 0xAE
    define output_time_speed, 0xAF
    define output_step_sync, 0xB0
    define output_time_sync, 0xB1
    define output_clr_count, 0xB2
    define output_get_count, 0xB3
    # Memory
    define file, 0xC0
    define array, 0xc1
    define array_write, 0xc2
    define array_read, 0xc3
    define array_append, 0xc4
    define memory_usage, 0xc5
    define file_name, 0xc6
    # Mailbox
    define mailbox_open, 0xD8
    define mailbox_write, 0xD9
    define mailbox_read, 0xDA
    define mailbox_test, 0xDB
    define mailbox_ready, 0xDC
    define mailbox_close, 0xDD
  end

  defmodule SoundSubCodes do
    define break, 0
    define tone, 1
    define play, 2
    define repeat, 3
    define service, 4
  end

  defmodule InputSubCodes do
    define get_format, 2
    define cal_min_max, 3
    define cal_default, 4
    define get_type_mode, 5
    define get_symbol, 6
    define cal_min, 7
    define cal_max, 8
    define setup, 9
    define clear_all, 10
    define get_raw, 11
    define get_connection, 12
    define stop_all, 13
    define get_name, 21
    define get_mode_name, 22
    define set_raw, 23
    define get_figures, 24
    define get_changes, 25
    define clr_changes, 26
    define ready_pct, 27
    define ready_raw, 28
    define ready_si, 29
    define get_min_max, 30
    define get_bumps, 31
  end

  defmodule FileSubCodes do
    define open_append, 0
    define open_read, 1
    define open_write, 2
    define read_value, 3
    define write_value, 4
    define read_text, 5
    define write_text, 6
    define close, 7
    define load_image, 8
    define get_handle, 9
    define load_picture, 10
    define get_pool, 11
    define unload, 12
    define get_folders, 13
    define get_icon, 14
    define get_subfolder_name, 15
    define write_log, 16
    define c_lose_log, 17
    define get_image, 18
    define get_item, 19
    define get_cache_files, 20
    define put_cache_file, 21
    define get_cache_file, 22
    define del_cache_file, 23
    define del_subfolder, 24
    define get_log_name, 25
    define get_cache_name, 26
    define open_log, 27
    define read_bytes, 28
    define write_bytes, 29
    define remove, 30
    define move, 31
  end

  defmodule MemorySubCodes do
    define delete, 0
    define create8, 1
    define create16, 2
    define create32, 3
    define create_tef, 4
    define resize, 5
    define fill, 6
    define copy, 7
    define init8, 8
    define init16, 9
    define init32, 10
    define init_f, 11
    define size, 12
  end

end
