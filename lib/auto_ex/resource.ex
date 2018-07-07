defmodule AutoEx.Resource do
  @moduledoc """
  """

  @type ok :: {:ok, payload :: any}
  @type ok_state :: {:ok, state :: any}
  @type ok_payload_state :: {:ok, payload :: any, state :: any}
  @type error :: {:error, reason :: String.t()}
  @type error_state :: {:error, reason :: String.t(), state :: any}
  @type result :: ok | error
  @type result_state :: ok_state | ok_payload_state | error_state
  @type terminate_reason :: :normal | :shutdown | {:shutdown, term()}

  @callback init(args :: any) :: ok_state | error
  @callback terminate(reason :: terminate_reason, state :: any) :: any
  @callback on_create(args :: any, state :: any) :: result_state
  @callback on_read(args :: any, state :: any) :: result_state
  @callback on_update(args :: any, state :: any) :: result_state
  @callback on_delete(args :: any, state :: any) :: result_state

  def __using__(_) do
    quote do
      @behaviour AutoEx.Resource
    end
  end

  # Public
  @doc "Start new resource process."
  @spec start(module(), any(), GenServer.options()) :: GenServer.server()
  def start(module, args \\ :ok, options \\ []) do
    GenServer.start(__MODULE__, %{module: module, args: args}, options)
  end

  @doc "Start and link new resource process."
  @spec start_link(module(), any(), GenServer.options()) :: GenServer.server()
  def start_link(module, args \\ :ok, options \\ []) do
    GenServer.start_link(__MODULE__, %{module: module, args: args}, options)
  end

  @doc "Create (POST) operation"
  @spec create(GenServer.server(), any) :: any
  def create(pid, args) do
    GenServer.call(pid, {:crud, :on_create, args})
  end

  @doc "Read/Get (GET) operation"
  @spec read(GenServer.server(), any) :: any
  def read(pid, args) do
    GenServer.call(pid, {:crud, :on_read, args})
  end

  @doc "Update (PUT/PATCH) operation"
  @spec update(GenServer.server(), any) :: any
  def update(pid, args) do
    GenServer.call(pid, {:crud, :on_update, args})
  end

  @doc "Delete (DELETE) operation"
  @spec delete(GenServer.server(), any) :: any
  def delete(pid, args) do
    GenServer.call(pid, {:crud, :on_delete, args})
  end

  # Callbacks
  @doc false
  def init(%{module: module, args: args}) do
    case module.init(args) do
      {:ok, state} -> {:ok, %{module: module, state: state}}
      {:error, reason} -> {:stop, reason}
    end
  end

  @doc false
  def handle_call({:crud, fun, args}, _from, %{module: module, state: state} = master_state) do
    case apply(module, fun, [args, state]) do
      {:ok, new_state} ->
        {:reply, :ok, Map.put(master_state, :state, new_state)}
      {:ok, payload, new_state} ->
        {:reply, payload, Map.put(master_state, :state, new_state)}
      {:error, reason, new_state} ->
        {:reply, {:error, reason}, Map.put(master_state, :state, new_state)}
    end
  end
end
