defmodule MinerAdmin.Model.Query.User do
  alias MinerAdmin.Model

  @repo Model.Repo
  @schema Model.Schema.User

  def count, do: @repo.aggregate(@schema, :count, :id)

  def all, do: @repo.all(@schema)

  def get(id) do
    @schema
    |> @repo.get(id)
    |> @repo.preload([:auth_backend])
  end

  def get_by(params) do
    @schema
    |> @repo.get_by(params)
    |> @repo.preload([:auth_backend])
  end
end
