defmodule MinerAdmin.Model.Query do
  defmacro __using__(_opts) do
    quote do
      alias MinerAdmin.Model
      alias MinerAdmin.Model.Schema
      alias MinerAdmin.Model.Query
      import Ecto.Query, only: [from: 2]

      @repo Model.Repo
      @schema Module.concat([Model.Schema, __MODULE__ |> Module.split() |> List.last()])

      def repo, do: @repo
      def schema, do: @schema
    end
  end
end
