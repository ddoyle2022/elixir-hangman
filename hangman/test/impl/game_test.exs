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

  test "Verify game lowercases guesses" do
    game = Game.new_game("burger")
    { game, _tally } = Game.make_move(game, "b")
    { game, _tally } = Game.make_move(game, "U")
    assert MapSet.equal?(game.used, MapSet.new(["b", "u"]))
  end

  test "Verify game recognizes letters in the word" do
    game = Game.new_game("bob")
    { _game, tally } = Game.make_move(game, "b")
    assert tally.game_state == :good_guess
  end

  test "Verify game recognizes when letter isn't in the word" do
    game = Game.new_game("bob")
    { _game, tally } = Game.make_move(game, "z")
    assert tally.game_state == :bad_guess
  end

  test "can handle a sequence of moves" do
    [
      # guess | state     turns  letters                     used
      ["a", :bad_guess,    6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess,   6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess,    5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a winning game" do
    [
      # guess | state     turns  letters                     used
      ["a", :bad_guess,    6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess,   6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess,    5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]],
      ["l", :good_guess,   5, ["_", "e", "l", "l", "_"], ["a", "e", "l", "x"]],
      ["o", :good_guess,   5, ["_", "e", "l", "l", "o"], ["a", "e", "l", "o", "x"]],
      ["y", :bad_guess,    4, ["_", "e", "l", "l", "o"], ["a", "e", "l", "o", "x", "y"]],
      ["h", :won,          4, ["h", "e", "l", "l", "o"], ["a", "e", "h", "l", "o", "x", "y"]],
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a losing game" do
    [
      # guess | state     turns  letters                     used
      ["a", :bad_guess,    6, ["_", "_", "_", "_", "_"], ["a"]],
      ["b", :bad_guess,    5, ["_", "_", "_", "_", "_"], ["a", "b"]],
      ["c", :bad_guess,    4, ["_", "_", "_", "_", "_"], ["a", "b", "c"]],
      ["d", :bad_guess,    3, ["_", "_", "_", "_", "_"], ["a", "b", "c", "d"]],
      ["e", :good_guess,   3, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e"]],
      ["f", :bad_guess,    2, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f"]],
      ["g", :bad_guess,    1, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g"]],
      ["h", :good_guess,   1, ["h", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g", "h"]],
      ["i", :lost,         0, ["h", "e", "l", "l", "o"], ["a", "b", "c", "d", "e", "f", "g", "h", "i"]],
    ]
    |> test_sequence_of_moves()
  end


  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_one_move/2)
  end

  defp check_one_move([ guess, state, turns, letters, used ], game) do
    { game, tally } = Game.make_move(game, guess)

    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.used == used

    game
  end
end
