defmodule WarehouseGitpod.Supervisor do
  use Supervisor
  
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end
  
  def init(_) do
    children = [
      worker(WarehouseGitpod.Receiver, [])
    ]
    
    supervise(children, strategy: :one_for_all)
  end
end
