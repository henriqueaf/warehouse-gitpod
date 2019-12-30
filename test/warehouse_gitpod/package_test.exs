defmodule WarehouseGitpod.PackageTest do
  use ExUnit.Case
  alias WarehouseGitpod.Package
  doctest WarehouseGitpod.Package

  describe "new(content)" do
    test "returns a new package stuct with content" do
      assert %Package{id: _id, contents: 'Some content'} = Package.new('Some content')
    end
  end
end
