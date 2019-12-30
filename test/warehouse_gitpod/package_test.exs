defmodule WarehouseGitpod.PackageTest do
  use ExUnit.Case
  alias WarehouseGitpod.Package
  doctest WarehouseGitpod.Package

  describe "new(content)" do
    test "returns a new package stuct with content" do
      assert %Package{id: _id, contents: 'Some content'} = Package.new('Some content')
    end
  end
  
  describe "random()" do
    test "returns a new package stuct with random content" do
      assert %Package{id: _id, contents: random_content} = Package.random()
      assert Enum.member?(["Bat", "Ball", "Book", "Broom"], random_content)
    end
  end
  
  describe "random_batch(n)" do
    test "returns n number of packages stucts with random contents" do
      assert [
        %Package{id: _id1, contents: _content1},
        %Package{id: _id2, contents: _content2}
      ] = Package.random_batch(2)
    end
  end
end
