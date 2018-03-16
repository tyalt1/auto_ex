# AutoEx

An event-driven automation framework for Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `auto_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:auto_ex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/auto_ex](https://hexdocs.pm/auto_ex).

## Documentation

### Signal

A signal is an event that triggers all actions linked to it.

```elixir
alias AutoEx.Signal

{:ok, pid} = Signal.start_link()
Signal.run(pid)
```

### Action

An action is a stand alone function.

```elixir
alias AutoEx.Action

action = Action.new(fn -> IO.puts "Performing action!" end)
Action.run(action)
```

### Link Signal with Actions

When an action is added to a signal, it is run whenever the signal is.

```elixir
alias AutoEx.Signal

{:ok, signal} = Signal.start_link()
action = Action.new(fn -> IO.puts "Performing action!" end)
Signal.add_action(signal, action)
```

## TODO
- Tests!
- Action retry
- Logging when signal is fired
- Logging when action is executed (successful/failure)
