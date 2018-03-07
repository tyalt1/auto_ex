defmodule AutoEx.Action do
  @moduledoc """

  An action is a stand alone function.

  """

  use GenServer

  @type action :: GenServer.server()

  @type action_fun ::
          (() -> term)
          | {module :: atom, function :: atom, args :: [term]}

  @type state :: %{fun: action_fun}

  @doc "Start new action."
  @spec start_link(action_fun) :: action
  def start_link(fun, options \\ []) do
    GenServer.start_link(__MODULE__, fun, options)
  end

  @doc "Manually trigger action."
  @spec run(action) :: :ok
  def run(action) do
    GenServer.call(action, :run)
  end

  @doc false
  def init(fun) do
    case fun do
      {module, function, args} ->
        {:ok, %{fun: {module, function, args}}}

      function when is_function(function, 0) ->
        {:ok, %{fun: function}}

      _ ->
        {:stop, :incorrect_action_fun}
    end
  end

  @doc false
  def handle_cast(:run, _from, state) do
    exec_action(state.fun)
    {:reply, state}
  end

  @doc false
  def handle_call(:run, _from, state) do
    {:reply, exec_action(state.fun), state}
  end

  @doc false
  defp exec_action(fun) do
    case fun do
      {module, function, args} -> apply(module, function, args)
      function when is_function(function, 0) -> apply(function, [])
    end
  end
end
