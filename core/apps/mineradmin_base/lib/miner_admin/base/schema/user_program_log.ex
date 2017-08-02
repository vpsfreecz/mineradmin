defmodule MinerAdmin.Base.Schema.UserProgramLog do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinerAdmin.Base.Schema

  import EctoEnum, only: [defenum: 2]
  defenum Type, start: 0, stop: 1, exit: 2, attach: 3, detach: 4

  schema "user_program_logs" do
    belongs_to :user_program, Schema.UserProgram
    belongs_to :user_session, Schema.UserSession
    field :type, Type
    field :opts, :map

    timestamps()
  end

  def changeset(log, params) do
    log
    |> cast(params, ~w(user_program_id user_session_id type opts)a)
    |> validate_required(~w(user_program_id type)a)
    |> assoc_constraint(:user_program)
    |> assoc_constraint(:user_session)
  end
end
