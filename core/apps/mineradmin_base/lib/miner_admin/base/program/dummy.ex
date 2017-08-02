defmodule MinerAdmin.Base.Program.Dummy do
  @behaviour MinerAdmin.Base.Program

  def changeset(changeset, _type), do: changeset

  def can_start?(_user_prog), do: true

  def command(_user_prog) do
    {"dummy", []}
  end

  def read_only?(_user_prog), do: false
end
