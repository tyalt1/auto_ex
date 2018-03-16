defmodule AutoEx.Action do
  @moduledoc """

  An action is a stand alone function.

  """

  @enforce_keys [:fun]
  defstruct [
    :fun
  ]

  @opaque action :: %AutoEx.Action{fun: action_fun}

  @type action_fun :: {:fun, (() -> term)} | {:mfa, {module, atom, [term]}}

  @doc "Create new Action."
  @spec new(action_fun) :: action
  def new(function) when is_function(function, 0) do
    %AutoEx.Action{fun: {:fun, function}}
  end
  def new({module, function, args}) do
    %AutoEx.Action{fun: {:mfa, {module, function, args}}}
  end

  @doc "Perform Action. NOTE: This call is blocking."
  @spec run(action) :: :ok
  def run(action = %AutoEx.Action{}) do
    do_action(action.fun)
    :ok
  end

  @doc false
  defp do_action(fun) do
    case fun do
      {:mfa, {module, function, args}} -> apply(module, function, args)
      {:fun, function} -> apply(function, [])
    end
  end
end
