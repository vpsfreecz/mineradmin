defmodule MinerAdmin.Model.User do
  # TODO: should return true/false and let controllers translate that to
  #   allow/deny
  def admin?(user) do
    if user.role == 0, do: :allow, else: :deny
  end
end
