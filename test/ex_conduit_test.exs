defmodule ExConduitTest do
  use ExUnit.Case
  doctest ExConduit

  test "greets the world" do
    assert ExConduit.hello() == :world
  end
end
