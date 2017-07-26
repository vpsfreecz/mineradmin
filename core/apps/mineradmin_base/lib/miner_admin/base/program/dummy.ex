defmodule MinerAdmin.Base.Program.Dummy do
  @behaviour MinerAdmin.Base.Program

  def command(_user_program) do
    {"dummy", []}
  end
end
