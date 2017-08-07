defmodule MinerAdmin.Base.Query do
  require Ecto.Query

  defmacro __using__(_opts) do
    quote do
      alias MinerAdmin.Base
      alias MinerAdmin.Base.Schema
      alias MinerAdmin.Base.Query
      import Ecto.Query, only: [from: 2]
      import unquote(__MODULE__)

      @repo Base.Repo
      @schema Module.concat([Base.Schema, __MODULE__ |> Module.split() |> List.last()])

      def repo, do: @repo
      def schema, do: @schema
    end
  end

  def paginate(queryable, opts) do
    Enum.reduce(
      opts,
      queryable,
      fn
        {:limit, v}, acc -> limit(acc, v)
        {:offset, v}, acc -> offset(acc, v)
      end
    )
  end

  defp limit(queryable, nil), do: queryable
  defp limit(queryable, v) when is_integer(v), do: Ecto.Query.limit(queryable, ^v)

  defp offset(queryable, nil), do: queryable
  defp offset(queryable, v) when is_integer(v), do: Ecto.Query.offset(queryable, ^v)
end
