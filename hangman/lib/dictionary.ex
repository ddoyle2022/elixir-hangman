defmodule Dictionary do

  def hello do
    IO.puts("Hello World!!!")
  end

  def get_word_list() do
    "../hangman/assets/words.txt"
    |> File.read!()
    |> String.split( ~r/\n/, trim: true)
  end

  def get_random_word() do
    get_word_list()
    |> Enum.random()
  end
end
