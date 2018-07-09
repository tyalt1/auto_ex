defmodule AutoEx.Action do
  @moduledoc """

  An action is a stand alone function.

  """

  alias AutoEx.Action
  @enforce_keys [:fun]
  defstruct [:fun, async: false]

  @type t :: %Action{fun: action_fun, async: boolean}
  @type action_fun :: {:fun, (() -> term)} | {:mfa, module, atom, [term]}

  @doc "Create new Action."
  @spec new((() -> term) | {module, atom, [term]}, [term]) :: t
  def new(fun, opts \\ []) when is_function(fun, 0) do
    %Action{
      fun: {:fun, fun},
      async: Keyword.get(opts, :async, false)
    }
  end

  def new(module, fun, args, opts \\ [])
      when is_atom(module) and is_atom(fun) and is_list(args) do
    %Action{
      fun: {:mfa, module, fun, args},
      async: Keyword.get(opts, :async, false)
    }
  end

  @doc "Perform Action. This call is blocking if async option is false."
  @spec run(t) :: :ok
  def run(%Action{fun: {:fun, fun}, async: true}) do
    Task.start(fun)
  end

  def run(%Action{fun: {:fun, fun}, async: false}) do
    apply(fun, [])
  end

  def run(%Action{fun: {:mfa, module, fun, args}, async: true}) do
    Task.start(module, fun, args)
  end

  def run(%Action{fun: {:mfa, module, fun, args}, async: false}) do
    apply(module, fun, args)
  end
end
