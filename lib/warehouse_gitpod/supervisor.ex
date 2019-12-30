defmodule WarehouseGitpod.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  # It starts automatically WarehouseGitpod.Receiver GenServer.
  # So you can call the WarehouseGitpod.Receiver methods without call start_link before.

  def init(_) do
    children = [
      worker(WarehouseGitpod.Receiver, [])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
