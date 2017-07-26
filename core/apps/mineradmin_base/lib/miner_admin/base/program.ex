defmodule MinerAdmin.Base.Program do
  @callback command(map) :: {String.t, list}

  def command(user_program) do
    {cmd, args} = module(user_program).command(user_program)
    {user_program.id, cmd, args}
  end

  def module(user_program) do
    Module.concat([user_program.program.module])
  end
end
