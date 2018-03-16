defmodule MockWork do
  def new do
    {:ok, work} = Agent.start_link(fn -> false end)
    work
  end

  def do_work(work) do
    Agent.update(work, fn _ -> true end)
  end

  def is_done(work) do
    Agent.get(work, fn x -> x end)
  end
end

defmodule AutoExTest do
  use ExUnit.Case
  alias AutoEx.Signal
  alias AutoEx.Action

  doctest AutoEx

  test "basic signal" do
    work = MockWork.new

    action = Action.new({MockWork, :do_work, [work]})

    {:ok, signal} = Signal.start_link()
    Signal.add_action(signal, action)
    Signal.run(signal)

    assert MockWork.is_done(work) == true
  end

  test "signal with multiple actions" do
    work1 = MockWork.new
    work2 = MockWork.new
    work3 = MockWork.new

    action1 = Action.new({MockWork, :do_work, [work1]})
    action2 = Action.new({MockWork, :do_work, [work2]})
    action3 = Action.new({MockWork, :do_work, [work3]})

    {:ok, signal} = Signal.start_link()
    Signal.add_action(signal, [action1, action2, action3])
    Signal.run(signal)

    assert MockWork.is_done(work1) == true
    assert MockWork.is_done(work2) == true
    assert MockWork.is_done(work3) == true
  end
end
