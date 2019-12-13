defmodule BefungeTest do
  use ExUnit.Case
  doctest Befunge

  test "greets the world" do
    assert Befunge.hello() == :world
  end
end
