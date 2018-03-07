defmodule AutoEx.Signal do
  @moduledoc """

  A signal is an event that triggers all actions linked to it.

  """

  use GenServer
  alias AutoEx.Action

  @type signal :: GenServer.server()

  @spec start_link([term]) :: {:ok, pid | atom}
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, nil, options)
  end

  @doc "Get action associated with signal."
  @spec get_action(signal) :: nil | Action.action()
  def get_action(signal) do
    GenServer.call(signal, :get_action)
  end

  @doc "Add action associated with signal."
  def add_action(signal, action) do
    GenServer.cast(signal, {:add_action, action})
  end

  @doc "Trigger action associated with signal. This call is blocking."
  @spec run(signal) :: :ok | :no_action
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
  def init(_args) do
    {:ok, %{action: nil}}
  end

  @doc false
  def handle_cast({:add_action, action}, state) do
    {:noreply, %{state | action: action}}
  end

  def handle_cast(:run, state = %{action: action}) do
    do_run(action)
    {:noreply, state}
  end

  @doc false
  def handle_call(:get_action, _from, state = %{action: action}) do
    {:reply, action, state}
  end

  def handle_call(:run, _from, state = %{action: action}) do
    {:reply, do_run(action), state}
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
