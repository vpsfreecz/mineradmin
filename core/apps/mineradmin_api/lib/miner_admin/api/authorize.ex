defmodule MinerAdmin.Api.Authorize do
  alias MinerAdmin.Base

  def admin(%Base.Schema.UserSession{} = session) do
    admin(session.user)
  end

  def admin(%Base.Schema.User{} = user) do
    if Base.User.admin?(user), do: :allow, else: :deny
  end
end
