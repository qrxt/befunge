defmodule BefungeTest do
  use ExUnit.Case
  doctest Befunge

  test "vertical if ( | ) works correct 1" do
    program =
      "v>1.@" <> "\n" <>
      ">|   " <> "\n" <>
      " >2.@"

    assert Befunge.exec(program) == "1"
  end
end
