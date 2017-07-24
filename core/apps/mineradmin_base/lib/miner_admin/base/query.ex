defmodule MinerAdmin.Base.Query do
  defmacro __using__(_opts) do
    quote do
      alias MinerAdmin.Base
      alias MinerAdmin.Base.Schema
      alias MinerAdmin.Base.Query
      import Ecto.Query, only: [from: 2]

      @repo Base.Repo
      @schema Module.concat([Base.Schema, __MODULE__ |> Module.split() |> List.last()])

      def repo, do: @repo
      def schema, do: @schema
    end
  end
end
