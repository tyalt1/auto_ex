defmodule Person do
  use AutoEx.Resource

  def init(_) do
    tid = :ets.new(:person_tab, [:ordered_set, :private])
    {:ok, tid}
  end

  def start_link() do
    AutoEx.Resource.start_link(__MODULE__)
  end

  def on_create(person_map, tid) do
    id = UUID.uuid1()
    person_map = Map.put(person_map, :id, id)
    true = :ets.insert_new(tid, from_map(person_map))

    {:ok, id, tid}
  end

  def on_read(:all, tid) do
    {:ok, Enum.map(:ets.tab2list(tid), &to_map/1), tid}
  end

  def on_read(id, tid) do
    case :ets.lookup(tid, id) do
      [] -> {:error, "no person found"}
      [person] -> {:ok, to_map(person), tid}
    end
  end

  def on_update(person_map, tid) do
    :ets.insert(tid, from_map(person_map))
    {:ok, :ok, tid}
  end

  def on_delete(id, tid) do
    :ets.delete(tid, id)
    {:ok, :ok, tid}
  end

  def from_map(%{id: id, name: name, age: age}), do: {id, name, age}
  def to_map({id, name, age}), do: %{id: id, name: name, age: age}
end

defmodule ResourceTest do
  use ExUnit.Case
  alias AutoEx.Resource

  test "create person" do
    {:ok, pid} = Person.start_link()
    bob = %{name: "bob", age: 21}

    assert [] === Resource.read(pid, :all)

    bob_id = Resource.create(pid, bob)
    bob = Map.put(bob, :id, bob_id)
    assert bob === Resource.read(pid, bob_id)
    assert [bob] === Resource.read(pid, :all)
  end
end
