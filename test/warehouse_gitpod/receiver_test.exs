defmodule WarehouseGitpod.ReceiverTest do
  use ExUnit.Case
  doctest WarehouseGitpod.Receiver
  alias WarehouseGitpod.{Receiver, Package}

  setup_all do
    # This setup will be available as second parameter on each test case
    {:ok, packages: Package.random_batch(1)}
  end

  describe "#receive_packages(packages)" do
    test "save packages assignments into Receiver state before send them to deliverators", %{packages: packages} do
      assert :ok = Receiver.receive_packages(packages)
      %{assignments: assignments} = :sys.get_state(Receiver)
      assert Enum.count(assignments) > 0
    end

    test "starts deliverator process to deliver the packages", %{packages: packages} do
      Receiver.receive_packages(packages)
      %{assignments: assignments} = :sys.get_state(Receiver)
      Enum.each(assignments, fn({_package, deliverator}) -> assert Process.alive?(deliverator) end)
    end
  end
end
