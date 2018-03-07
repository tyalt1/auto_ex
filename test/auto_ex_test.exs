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

  test "signal with multiple actions" do
    {:ok, task1} = Agent.start_link(fn -> false end)
    {:ok, task2} = Agent.start_link(fn -> false end)
    {:ok, task3} = Agent.start_link(fn -> false end)

    {:ok, action1} = Action.start_link({Agent, :update, [task1, fn _ -> true end]})
    {:ok, action2} = Action.start_link({Agent, :update, [task2, fn _ -> true end]})
    {:ok, action3} = Action.start_link({Agent, :update, [task3, fn _ -> true end]})

    {:ok, signal} = Signal.start_link()
    Signal.add_action(signal, [action1, action2, action3])
    Signal.run(signal)

    assert Agent.get(task1, fn x -> x end) == true
    assert Agent.get(task2, fn x -> x end) == true
    assert Agent.get(task3, fn x -> x end) == true
  end
end
