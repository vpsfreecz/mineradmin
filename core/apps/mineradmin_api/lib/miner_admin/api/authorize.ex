defmodule MinerAdmin.Api.Authorize do
  alias MinerAdmin.Base

  def admin(user) do
    if Base.User.admin?(user), do: :allow, else: :deny
  end
end
