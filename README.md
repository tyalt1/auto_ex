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

Signal.start_link(name: MySignal) #Create named signal
Signal.run(MySignal) #Call all actions linked with signal
```

### Action

An action is a stand alone function.

```elixir
alias AutoEx.Action

Action.start_link(fn -> IO.puts "Performing action!" end, name: MyAction)
Action.run(MyAction)
```

### Link Signal with Actions

When an action is added to a signal, it is run whenever the signal is.

```elixir
alias AutoEx.Signal
Signal.add_action(MySignal, MyAction)
```

## TODO
- Tests!
- Signal has multiple actions
- Action retry
- Logging when signal is fired
- Logging when action is executed (successful/failure)
