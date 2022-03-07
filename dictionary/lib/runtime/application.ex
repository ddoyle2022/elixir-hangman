defmodule Dictionary.Runtime.Application do

  use Application

  # Like main() in OOP/procedural languages
  def start(_type, _args) do
    Dictionary.Runtime.Server.start_link()
  end
end
