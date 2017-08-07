defmodule MinerAdmin.Api.User.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.User.Params
  end

  def authorize(%HaveAPI.Request{}, _session), do: :allow
  def authorize(_res, session) do
    if Base.User.admin?(session) do
      :allow

    else
      {:allow, blacklist: [:auth_backend]}
    end
  end

  def find(req) do
    req.params[:user_id]
    |> user_id()
    |> do_find(req.user.user_id, Base.User.admin?(req.user))
  end

  def check(req, item), do: Base.User.admin?(req.user) || item.id == req.user.user_id

  def return(_req, item), do: Api.resourcify(item, [:auth_backend])

  defp user_id(id) when is_binary(id), do: String.to_integer(id)
  defp user_id(id) when is_integer(id), do: id

  defp do_find(id, _user_id, true), do: Base.Query.User.get(id)
  defp do_find(user_id, user_id, false), do: Base.Query.User.get(user_id)
  defp do_find(_, _, false), do: nil
end
