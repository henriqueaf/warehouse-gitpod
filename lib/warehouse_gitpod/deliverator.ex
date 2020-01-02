defmodule WarehouseGitpod.Deliverator do
  use GenServer
  alias WarehouseGitpod.{Receiver}

  # Created init method to dismiss a warning saiyng
  # that init method is required by GenServer

  # API Methods

  def start do
    GenServer.start(__MODULE__, [])
  end

  def deliver_packages(pid, packages) do
    GenServer.cast(pid, {:deliver_packages, packages})
  end

  # SERVER Methods

  def init(init_args) do
    {:ok, init_args}
  end

  def handle_cast({:deliver_packages, packages}, state) do
    deliver(packages)
    {:noreply, state}
  end

  defp deliver([]), do: send(Receiver, {:deliverator_idle, self()})
  defp deliver([package | remaining_packages]) do
    IO.puts "Deliverator #{inspect self()} delivering #{inspect package}"
    make_delivery()
    send(Receiver, {:package_delivered, package})
    deliver(remaining_packages)
  end

  defp make_delivery do
    :timer.sleep :rand.uniform(1_000)
    maybe_crash()
  end

  defp maybe_crash do
    crash_factor = :rand.uniform(100)
    IO.puts "Crash factor: #{crash_factor}"
    if crash_factor > 60, do: raise "Oh no! Going down"
  end
end
