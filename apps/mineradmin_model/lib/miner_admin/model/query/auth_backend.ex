defmodule MinerAdmin.Model.Query.AuthBackend do
  use MinerAdmin.Model.Query

  def all do
    @repo.all(@schema)
  end
end
