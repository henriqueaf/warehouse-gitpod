defmodule WarehouseGitpod.DeliveratorTest do
  use ExUnit.Case
  alias WarehouseGitpod.{Deliverator, Package}
  doctest Deliverator

  setup_all do
    {:ok, packages: Package.random_batch(1)}
  end

  describe "deliver_packages(pid, packages)" do
    test "creates a deliverator process to deliver the packages", %{packages: packages} do
      {:ok, pid} = Deliverator.start()
      Process.monitor(pid)

      Deliverator.deliver_packages(pid, packages)

      :timer.sleep 1_100
      assert_received({:DOWN, _ref, :process, _pid, _reason})
    end
  end
end
