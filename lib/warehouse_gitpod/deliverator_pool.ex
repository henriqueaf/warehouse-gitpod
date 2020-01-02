defmodule WarehouseGitpod.DeliveratorPool do
  use GenServer
  alias WarehouseGitpod.{Deliverator}
  @max 20

  # API Methods

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Returns the @max constant.
  ## Examples
    iex> WarehouseGitpod.DeliveratorPool.max
    20
  """
  def max, do: @max

  @doc """
  Returns {:ok, pid} or {:error, message}.
  ## Examples
    iex> {:ok, pid} = WarehouseGitpod.DeliveratorPool.available_deliverator()
    iex> is_pid pid
    true
  """
  def available_deliverator do
    GenServer.call(__MODULE__, {:fetch_available_deliverator})
  end

  @doc """
  Changes deliverator status to busy.
  ## Examples
    iex> {:ok, pid} = WarehouseGitpod.DeliveratorPool.available_deliverator
    iex> WarehouseGitpod.DeliveratorPool.flag_deliverator_busy(pid)
    iex> %{deliverators: [{pid, :busy} | _tail]} = :sys.get_state(WarehouseGitpod.DeliveratorPool)
    iex> is_pid pid
    true
  """
  def flag_deliverator_busy(deliverator) do
    GenServer.call(__MODULE__, {:flag_deliverator, :busy, deliverator})
  end

  @doc """
  Changes deliverator status to idle.
  ## Examples
    iex> {:ok, pid} = WarehouseGitpod.DeliveratorPool.available_deliverator()
    iex> WarehouseGitpod.DeliveratorPool.flag_deliverator_idle(pid)
    iex> %{deliverators: [{pid, :idle} | _tail]} = :sys.get_state(WarehouseGitpod.DeliveratorPool)
    iex> is_pid pid
    true
  """
  def flag_deliverator_idle(deliverator) do
    GenServer.call(__MODULE__, {:flag_deliverator, :idle, deliverator})
  end

  def remove_deliverator(deliverator) do
    GenServer.call(__MODULE__, {:remove_deliverator, deliverator})
  end

  # SERVER Methods

  def init(_init_arg) do
    state = %{
      deliverators: []
    }

    {:ok, state}
  end

  @doc """
  1. Find idle deliverator from the pool
  2. If none found, check if number of deliverators is less than max
  3. If less than max, start a new deliverator, add to the pool as idle and return {:ok, pid}
  4. If over than max, return {:error, message}
  """
  def handle_call({:fetch_available_deliverator}, _from, state) do
    idle_deliverator =
      state.deliverators
      |> Enum.find(&match?({_deliverator, :idle}, &1))

    {status, message, state} = case idle_deliverator do
      nil ->
        if Enum.count(state.deliverators) >= @max do
          {:error, "deliverator pool maxed out", state}
        else
          {:ok, deliverator} = Deliverator.start
          deliverator_entry = {deliverator, :idle}
          deliverators = [deliverator_entry | state.deliverators]
          state = %{state | deliverators: deliverators}

          {:ok, deliverator, state}
        end
      {deliverator, _status} ->
        # found idle deliverator
        {:ok, deliverator, state}
      response -> raise "Unexpected format #{inspect response}"
    end

    {:reply, {status, message}, state}
  end

  def handle_call({:flag_deliverator, flag, deliverator}, _from, state) do
    deliverator_index =
      state.deliverators
      |> Enum.find_index(&match?({^deliverator, _flag}, &1))

    deliverators = List.replace_at(state.deliverators, deliverator_index, {deliverator, flag})
    new_state = %{state | deliverators: deliverators}

    {:reply, :ok, new_state}
  end

  def handle_call({:remove_deliverator, deliverator}, _from, state) do
    deliverator_entry =
      state.deliverators
      |> Enum.find(&match?({^deliverator, _flag}, &1))

    deliverators = List.delete(state.deliverators, deliverator_entry)
    new_state = %{state | deliverators: deliverators}

    {:reply, :ok, new_state}
  end
end
