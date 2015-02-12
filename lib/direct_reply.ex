defmodule EV3BT.DirectReply do
  use EV3BT.Constants

  @type reply_type :: :direct_reply_ok
                    | :direct_reply_error

  @reply_types %{CommandType.direct_reply            => :direct_reply_ok,
                 CommandType.system_reply_with_error => :direct_reply_error}


  @spec decode(reply::binary) :: %{:msg_counter => integer,
                                   :reply_type  => reply_type,
                                   :data        => binary}

  def decode(reply) do
    << length        :: size(16)-little,    # Byte 0 & 1
       msg_counter   :: size(16)-little,    # Byte 2 & 3
       reply_type    :: size(8),            # Byte 5
       data          :: binary >> = reply   # Byte 6 - n

    %{msg_counter: msg_counter,
      reply_type:  @reply_types[reply_type],
      data:        data}
  end

end
