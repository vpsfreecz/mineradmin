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

  def item(req) do
    req.params[:user_id]
    |> user_id()
    |> find(req.user.user_id, Base.User.admin?(req.user))
    |> Api.resourcify([:auth_backend])
  end

  defp user_id(id) when is_binary(id), do: String.to_integer(id)
  defp user_id(id) when is_integer(id), do: id

  defp find(id, _user_id, true), do: Base.Query.User.get(id)
  defp find(user_id, user_id, false), do: Base.Query.User.get(user_id)
  defp find(_, _, false), do: nil
end
