defmodule ElixirHangmanTest do
  use ExUnit.Case
  doctest ElixirHangman

  test "greets the world" do
    assert ElixirHangman.hello() == :world
  end
end
