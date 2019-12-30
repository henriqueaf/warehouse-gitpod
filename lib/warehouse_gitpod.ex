defmodule WarehouseGitpod do
  @moduledoc """
  The Application main module, used to start the main
  Supervisor module WarehouseGitpod.Supervisor.
  """
  use Application

  @doc """
  Executed when application starts. It starts the Supervisor module.
  ## Examples
    iex> Application.start(:warehouse_gitpod)
    {:error, {:already_started, :warehouse_gitpod}}
  """
  def start(_type, _args) do
    WarehouseGitpod.Supervisor.start_link()
  end
end
