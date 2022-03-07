# Private implementation of Dictionary
defmodule Dictionary.Impl.WordList do

  def word_list() do
    "../dictionary/assets/words.txt"
    |> File.read!()
    |> String.split( ~r/\n/, trim: true)
  end

  def random_word(word_list) do
    word_list
    |> Enum.random()
  end
end
