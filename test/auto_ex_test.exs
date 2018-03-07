defmodule AutoExTest do
  use ExUnit.Case
  alias AutoEx.Signal
  alias AutoEx.Action

  doctest AutoEx

  test "basic signal" do
    {:ok, test_passed} = Agent.start_link(fn -> false end)

    {:ok, action} = Action.start_link({Agent, :update, [test_passed, fn _ -> true end]})

    {:ok, signal} = Signal.start_link()
    Signal.add_action(signal, action)
    Signal.run(signal)

    assert Agent.get(test_passed, fn x -> x end) == true
  end
end
