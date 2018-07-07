defmodule AutoEx.Action do
  @moduledoc """

  An action is a stand alone function.

  """

  alias AutoEx.Action

  @enforce_keys [:fun]
  defstruct [:fun, async: false]

  @type t :: %AutoEx.Action{fun: action_fun, async: boolean}
  @type action_fun :: {:fun, (() -> term)} | {:mfa, {module, atom, [term]}}

  @doc "Create new Action."
  @spec new((() -> term) | {module, atom, [term]}, [term]) :: t
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
  @spec run(t) :: :ok
  def run(action = %Action{async: async}) do
    if async do
      Task.start(fn -> do_run(action) end)
    else
      do_run(action)
    end

    :ok
  end

  defp do_run(%AutoEx.Action{fun: fun}) do
    case fun do
      {:mfa, {module, function, args}} -> apply(module, function, args)
      {:fun, function} -> apply(function, [])
    end
  end
end
