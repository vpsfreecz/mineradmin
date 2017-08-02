defmodule MinerAdmin.Base.UserProgramLog do
  alias MinerAdmin.Base

  def log(user_prog, session, type, opts) do
    Base.Query.UserProgramLog.create(%{
      user_program_id: user_prog.id,
      user_session_id: session && session.id,
      type: type,
      opts: opts,
    })
  end
end
