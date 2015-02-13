defmodule EV3BT.ConnectionManager do
  use GenServer
  require Logger

  defmodule State do
    defstruct serial_pid: nil, last_reply: nil
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

  def send_command(cmd) do
    GenServer.cast(@name, {:send_command, cmd})
  end

  def receive_reply(timeout \\ 1000) do
    GenServer.call(@name, {:receive_reply, timeout})
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

  def handle_cast({:send_command, cmd}, state) do
    do_send_command(state.serial_pid, cmd)
    {:noreply, state}
  end

  def handle_call({:receive_reply, timeout}, _from, state) do
    reply = do_receive_reply(state.last_reply, timeout)
    {:reply, reply, %{state | last_reply: nil}}
  end


  def handle_info({:data, reply}, state) do
    {:noreply, %{state | last_reply: reply}}
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

  def do_send_command(pid, cmd) do
    send(pid, {:send, cmd})
  end

  def do_receive_reply(last_reply, timeout) do
    case last_reply do
      nil ->
        receive do
          {:data, reply} -> reply
        after
          timeout -> {:error, :timeout}
        end
      reply -> reply
    end

  end

end
