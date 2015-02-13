defmodule EV3BT.ConnectionManager do
  use GenServer
  require Logger
  alias EV3BT.DirectCommand
  alias EV3BT.DirectReply

  defmodule State do
    defstruct serial_pid: nil, msg_counter: 0, clients_queue: %{}
  end

  @name __MODULE__

  #
  # API
  #

  def start() do
    GenServer.start(__MODULE__, [], name: @name)
  end

  def stop() do
    GenServer.cast(@name, :stop)
  end

  @spec direct_command_sync(cmd::binary, opts::Keyword.t) :: reply::%{}
  def direct_command_sync(cmd, opts \\ []) do
    GenServer.call(@name, {:direct_command, :sync, cmd, opts})
  end

  @doc """
  Reply will be sent asynchronous in the following format:

      {:reply, msg_id::term, decoded_reply::%{}}

  """
  @spec direct_command_async(cmd::binary, opts::Keyword.t) :: {:ok, msg_id::term}
  def direct_command_async(cmd, opts \\ []) do
    GenServer.call(@name, {:direct_command, :async, cmd, opts})
  end

  @spec direct_command_no_reply(cmd::binary, opts::Keyword.t) :: :ok
  def direct_command_no_reply(cmd, opts \\ []) do
    GenServer.cast(@name, {:direct_command_no_reply, cmd, opts})
  end

  #
  # GenServer callbacks
  #

  def init(_args) do
    Logger.info("Starting connection manager")
    pid = connect()
    {:ok, %State{serial_pid: pid}}
  end

  def handle_cast(:stop, state) do
    Logger.info("Stopping connection manager")
    close(state.serial_pid)
    {:stop, :normal, state}
  end

  def handle_cast({:direct_command_no_reply, cmd, opts}, state) do
    msg_id = state.msg_counter
    do_direct_command(:cmd_no_reply, cmd, opts, state.serial_pid, msg_id)
    {:noreply, %{state | msg_counter: msg_id + 1}}
  end

  def handle_call({:direct_command, sync, cmd, opts}, from, state) do
    msg_id = state.msg_counter
    do_direct_command(:cmd_reply, cmd, opts, state.serial_pid, msg_id)
    Logger.debug("Reply for message #{msg_id} will be #{sync}")
    new_clients_queue = Map.put(state.clients_queue, msg_id, {sync, from})
    new_state = %{state | clients_queue: new_clients_queue,
                          msg_counter: msg_id + 1}
    case sync do
      :sync -> {:noreply, new_state}
      :async -> {:reply, {:ok, msg_id}, new_state}
    end
  end

  def handle_info({:data, reply}, state) do
    Logger.debug("Received reply: #{print_binary(reply)}")
    %{msg_counter: msg_id} = decoded_reply = DirectReply.decode(reply)
    case Map.get(state.clients_queue, msg_id) do
      nil ->
        Logger.warn("No awaiting process for message #{msg_id}")
      {:sync, client} ->
        Logger.debug("Sending sync reply to client for message #{msg_id}")
        GenServer.reply(client, decoded_reply)
      {:async, {pid, _ref}} ->
        Logger.debug("Sending async reply to client for message #{msg_id}")
        send(pid, {:reply, msg_id, decoded_reply})
    end
    {:noreply, %{state | clients_queue: Map.delete(state.clients_queue, msg_id)}}
  end

  #
  # Functions which interfaces to the serial connection
  #

  def connect() do
    :serial.start(speed: 57600, open: "/dev/tty.EV3-SerialPort")
  end

  def close(pid) do
    send(pid, {:close})
  end

  def do_send_command(cmd, pid) do
    send(pid, {:send, cmd})
  end

  def do_direct_command(cmd_type, cmd, opts, pid, msg_id) do
    Logger.debug("Sending command with ID #{msg_id}: #{print_binary(cmd)}")
    DirectCommand.encode(cmd_type, cmd, [{:msg_counter, msg_id} | opts])
    |> do_send_command(pid)
  end

  def print_binary(b) do
    "<<" <> (:erlang.binary_to_list(b) |> Enum.join ", ") <> ">>"
  end

end
