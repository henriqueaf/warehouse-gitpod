defmodule WarehouseGitpod.Receiver do
  use GenServer
  alias WarehouseGitpod.{Deliverator}

  @moduledoc """
  Module responsible to receive packages and delegates
  the delivery to Deliverators processes
  """

  # API Methods

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Method that chunck packages before send them to deliverators.
  ## Examples
    iex> packages = WarehouseGitpod.Package.random_batch(1)
    iex> WarehouseGitpod.Receiver.receive_and_chunck(packages)
    :ok
  """
  def receive_and_chunck(packages) do
    packages
    |> Enum.chunk_every(10)
    |> Enum.each(&receive_packages/1)
  end

  defp receive_packages(packages) do
    GenServer.cast(__MODULE__, {:receive_packages, packages})
  end

  # SERVER Methods

  @impl true
  def init(_) do
    state = %{
      assignments: []
    }

    {:ok, state}
  end

  @impl true
  def handle_cast({:receive_packages, packages}, state) do
    IO.puts "Received #{Enum.count(packages)} packages"
    {:ok, deliverator} = Deliverator.start
    Process.monitor(deliverator)
    state = assign_packages(state, packages, deliverator)
    Deliverator.deliver_packages(deliverator, packages)
    {:noreply, state}
  end

  @impl true
  def handle_info({:package_delivered, package}, state) do
    IO.puts "package #{inspect package} was delivered"
    delivered_assignments =
      state.assignments
      |> Enum.filter(fn({assigned_package, _pid}) -> assigned_package == package end)

    assignments = state.assignments -- delivered_assignments
    new_state = %{state | assignments: assignments}

    {:noreply, new_state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, deliverator, :normal}, state) do
    IO.puts "deliverator #{inspect deliverator} completed the mission and terminated"
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, deliverator, reason}, state) do
    IO.puts "deliverator #{inspect deliverator} went down. Details: #{inspect reason}"
    failed_assignments = filter_assignments_by_deliverator(deliverator, state.assignments)
    assignments = state.assignments -- failed_assignments
    new_state = %{state | assignments: assignments}

    failed_packages = failed_assignments |> Enum.map(fn({package, _deliverator}) -> package end)
    receive_packages(failed_packages)

    {:noreply, new_state}
  end

  defp assign_packages(state, packages, deliverator) do
    new_assignments = packages |> Enum.map(fn(package) -> {package, deliverator} end)
    assignments = state.assignments ++ new_assignments
    %{state | assignments: assignments}
  end

  defp filter_assignments_by_deliverator(deliverator, assignments) do
    assignments
    |> Enum.filter(
      fn({_package, assigned_deliverator}) ->
        assigned_deliverator == deliverator
      end
    )
  end
end
