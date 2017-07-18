defmodule MinerAdmin.Model.AuthBackend.Default do
  alias MinerAdmin.Model

  @behaviour Model.AuthBackend

  def authenticate(_opts, user, password) do
    if user.password == password do
      :ok

    else
      :incorrect_password
    end
  end

  def user_changeset(changeset, :create) do
    case Ecto.Changeset.fetch_change(changeset, :password) do
      {:ok, _pwd} ->
        changeset

      :error ->
        Ecto.Changeset.add_error(changeset, :password, "must be set")
    end
  end

  def user_changeset(changeset, :update), do: changeset
end
