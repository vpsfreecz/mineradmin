defmodule MinerAdmin.Model.Query.AuthBackend do
  import Ecto.Query, only: [from: 2]
  alias MinerAdmin.Model

  @repo Model.Repo
  @schema Model.Schema.AuthBackend

  def all do
    @repo.all(@schema)
  end
end
