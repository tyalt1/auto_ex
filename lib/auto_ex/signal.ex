defmodule AutoEx.Signal do
  @moduledoc """

  A signal is an event that triggers all actions linked to it.

  """

  use GenServer
  alias AutoEx.Action

  @type signal :: GenServer.server()
  @type state :: %{actions: MapSet.t(Action.action)}

  @doc "Start new signal."
  @spec start_link([term]) :: {:ok, pid | atom}
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, nil, options)
  end

  @doc "Get action associated with signal."
  @spec get_action(signal) :: MapSet.t(Action.action)
  def get_action(signal) do
    GenServer.call(signal, :get_action)
  end

  @doc "Add action associated with signal."
  @spec add_action(signal, Action.action | [Action.action]) :: :ok
  def add_action(signal, actions) when is_list(actions) do
    for action <- actions do
      GenServer.cast(signal, {:add_action, action})
    end
  end
  def add_action(signal, action) do
    GenServer.cast(signal, {:add_action, action})
  end

  @doc "Trigger action associated with signal. This call is blocking."
  @spec run(signal) :: [:ok | :no_action]
  def run(signal) do
    GenServer.call(signal, :run)
  end

  @doc "Trigger action associated with signal. This call is non-blocking."
  @spec async_run(signal) :: :ok
  def async_run(signal) do
    GenServer.cast(signal, :run)
  end

  # ----- Callbacks -----

  @doc false
  def init(nil) do
    {:ok, %{actions: MapSet.new}}
  end

  @doc false
  def handle_cast({:add_action, new_action}, state = %{actions: actions}) do
    {:noreply, %{state | actions: MapSet.put(actions, new_action)}}
  end

  def handle_cast(:run, state = %{actions: actions}) do
    Enum.each(actions, &do_run/1)
    {:noreply, state}
  end

  @doc false
  def handle_call(:get_action, _from, state = %{actions: actions}) do
    {:reply, actions, state}
  end

  def handle_call(:run, _from, state = %{actions: actions}) do
    {:reply, Enum.map(actions, &do_run/1), state}
  end

  @doc false
  defp do_run(action) do
    case action do
      nil ->
        :no_action

      action ->
        Action.run(action)
        :ok
    end
  end
end
