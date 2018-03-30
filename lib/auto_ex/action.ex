defmodule AutoEx.Action do
  @moduledoc """

  An action is a stand alone function.

  """

  alias AutoEx.Action

  @enforce_keys [:fun]
  defstruct [:fun, async: false]

  @opaque action :: %AutoEx.Action{fun: action_fun, async: boolean}

  @type action_fun :: {:fun, (() -> term)} | {:mfa, {module, atom, [term]}}

  @doc "Create new Action."
  @spec new(action_fun) :: action
  def new(fun, opts \\ []) do
    %Action{
      fun:
        case fun do
          {module, function, args} -> {:mfa, {module, function, args}}
          function when is_function(function, 0) -> {:fun, function}
        end,
      async: Keyword.get(opts, :async, false)
    }
  end

  @doc "Perform Action. NOTE: This call is blocking."
  @spec run(action) :: :ok
  def run(action = %Action{}) do
    do_run(action)
    :ok
  end

  defp do_run(%AutoEx.Action{fun: fun, async: false}) do
    case fun do
      {:mfa, {module, function, args}} -> apply(module, function, args)
      {:fun, function} -> apply(function, [])
    end
  end

  defp do_run(%AutoEx.Action{fun: fun, async: true}) do
    case fun do
      {:mfa, {module, function, args}} -> Task.start(module, function, args)
      {:fun, function} -> Task.start(function)
    end
  end
end
