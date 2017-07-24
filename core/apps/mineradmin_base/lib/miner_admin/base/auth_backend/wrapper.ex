defmodule MinerAdmin.Base.AuthBackend.Wrapper do
  use GenServer
  require Logger
  alias MinerAdmin.Base

  # Client API
  def start_link(backend, opts) do
    GenServer.start_link(__MODULE__, backend, opts)
  end

  def authenticate(backend, user, password) do
    GenServer.call(
      Base.AuthBackend.via_tuple(backend),
      {:authenticate, user, password},
      15_000
    )
  end

  # Server implementation
  def init(backend) do
    Process.flag(:trap_exit, true)
    GenServer.cast(self(), :init)

    {:ok, {backend, nil}}
  end

  def handle_cast(:init, {backend, nil}) do
    {:noreply, {backend, start_link_backend(backend)}}
  end

  def handle_call({:authenticate, _user, _password}, _from, {backend, nil}) do
    {:reply, {:error, "Authentication backend not available"}, {backend, nil}}
  end

  def handle_call({:authenticate, user, password}, _from, {backend, pid}) do
    {:reply, mod(backend).authenticate(pid, user, password), {backend, pid}}
  end

  def handle_info(:retry, {backend, nil}) do
    Logger.info "Restarting auth backend process of #{backend.module} (id=#{backend.id})"
    {:noreply, {backend, start_link_backend(backend)}}
  end

  def handle_info({:EXIT, _from, reason}, {backend, _pid}) do
    Logger.info "Auth backend process of #{backend.module} (id=#{backend.id}) " <>
      "exited with reason #{inspect(reason)}. Restarting in 30s."

    Process.send_after(self(), :retry, 30*1000)
    {:noreply, {backend, nil}}
  end

  defp start_link_backend(backend) do
    {:ok, pid} = mod(backend).start_link(backend.opts)
    pid
  end

  defp mod(backend), do: Module.concat([backend.module])
end
