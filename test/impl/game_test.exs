defmodule GameTest do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "Verify new game returns a struct" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "Verify new game returns correct word" do
    game = Game.new_game("bob")

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["b", "o", "b"]
  end

  test "Verify game word is all lowercase" do
    game = Game.new_game("BURGER")

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["b", "u", "r", "g", "e", "r"]
    assert true
  end

  test "Verify game state doesn't change if a game is won" do
    game = Game.new_game("bob")
    game = Map.put(game, :game_state, :won)
    { new_game, _tally } = Game.make_move(game, "z")
    assert new_game == game
  end

  test "Verify game state doesn't change if a game is lost" do
    game = Game.new_game("bob")
    game = Map.put(game, :game_state, :lost)
    { new_game, _tally } = Game.make_move(game, "a")
    assert new_game == game
  end

  test "When game receives duplicate letter, verify duplicate is reported" do
    game = Game.new_game("bob")
    { game, _tally } = Game.make_move(game, "z")
    assert game.game_state != :already_used
    { game, _tally } = Game.make_move(game, "a")
    assert game.game_state != :already_used
    { game, _tally } = Game.make_move(game, "z")
    assert game.game_state == :already_used
  end

  test "Verify guessed letters are recorded" do
    game = Game.new_game("bob")
    { game, _tally } = Game.make_move(game, "a")
    { game, _tally } = Game.make_move(game, "b")
    { game, _tally } = Game.make_move(game, "c")
    { game, _tally } = Game.make_move(game, "a")
    assert MapSet.equal?(game.used, MapSet.new(["a", "b", "c"]))
  end
end
