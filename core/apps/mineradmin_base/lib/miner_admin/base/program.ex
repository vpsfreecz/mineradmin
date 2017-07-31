defmodule MinerAdmin.Base.Program do
  alias MinerAdmin.Base

  @type user_program :: Ecto.Schema.t
  @type changeset :: Ecto.Changeset.t

  @doc "Validate user program's configuration on create and update."
  @callback changeset(user_program :: changeset, :create | :update) :: changeset

  @doc """
  Determines whether the user program is configured correctly and can be started.
  """
  @callback can_start?(user_program) :: true | {:error, String.t}

  @doc """
  Returns the command to be executed and its arguments.

  This function is called from the minwer worker node, so it has access to its
  processes directly. For example, one does not have to go through
  `MinerAdmin.Miner.Dispatcher` to communicate with workers.
  """
  @callback command(user_program) :: {String.t, [String.t]}

  def changeset(changeset, :create, user_program) do
    {:ok, prog_id} = Ecto.Changeset.fetch_change(changeset, :program_id)

    case Base.Query.Program.get(prog_id) do
      nil ->
        changeset

      prog ->
        Module.concat([prog.module]).changeset(changeset, :create)
    end
  end

  def changeset(changeset, :update, user_program) do
    module(user_program).changeset(changeset, :update)
  end

  def command(user_program) do
    {cmd, args} = module(user_program).command(user_program)
    {user_program.id, cmd, args}
  end

  def can_start?(user_program) do
    module(user_program).can_start?(user_program)
  end

  def module(user_program) do
    Module.concat([user_program.program.module])
  end
end
