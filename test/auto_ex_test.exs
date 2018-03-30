defmodule MockWork do
  defstruct [work: false, prework: nil, postwork: nil]

  def new(opts \\ []) do
    {:ok, work} = Agent.start_link(fn ->
      %MockWork{
        work: false,
        prework: Keyword.get(opts, :prework),
        postwork: Keyword.get(opts, :postwork),
      }
    end)
    work
  end

  def do_work(work) do
    do_prework(work)
    Agent.update(work, fn work_struct -> Map.put(work_struct, :work, true) end)
    do_postwork(work)
  end

  def do_prework(work) do
    prework = Agent.get(work, fn %MockWork{prework: prework} -> prework end)
    prework && prework.()
  end

  def do_postwork(work) do
    postwork = Agent.get(work, fn %MockWork{postwork: postwork} -> postwork end)
    postwork && postwork.()
  end

  def is_done(work) do
    Agent.get(work, fn %MockWork{work: work} -> work end)
  end
end

defmodule AutoExTest do
  use ExUnit.Case
  alias AutoEx.{Signal, Action}

  doctest AutoEx

  test "basic signal" do
    work = MockWork.new

    action = Action.new({MockWork, :do_work, [work]})

    {:ok, signal} = Signal.start_link()
    Signal.add_action(signal, action)
    Signal.run(signal)

    assert MockWork.is_done(work)
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

    assert Enum.all?([work1, work2, work3], &MockWork.is_done/1)
  end

  test "async actions" do
    work1 = MockWork.new(prework: fn -> :timer.sleep(1000) end)
    work2 = MockWork.new(prework: fn -> :timer.sleep(1000) end)
    work3 = MockWork.new(prework: fn -> :timer.sleep(1000) end)

    action1 = Action.new({MockWork, :do_work, [work1]}, async: true)
    action2 = Action.new({MockWork, :do_work, [work2]}, async: true)
    action3 = Action.new({MockWork, :do_work, [work3]}, async: true)

    {:ok, signal} = Signal.start_link()
    Signal.add_action(signal, [action1, action2, action3])
    Signal.run(signal)

    :timer.sleep(2000)
    assert Enum.all?([work1, work2, work3], &MockWork.is_done/1)
  end
end
