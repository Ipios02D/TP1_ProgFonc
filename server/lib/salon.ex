defmodule MiniDiscord.Salon do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{name: name, clients: [], historique: []},
      name: via(name))
  end

  def rejoindre(salon, pid), do: GenServer.call(via(salon), {:rejoindre, pid})
  def quitter(salon, pid),   do: GenServer.call(via(salon), {:quitter, pid})
  def broadcast(salon, msg), do: GenServer.cast(via(salon), {:broadcast, msg})
  def lister do
    Registry.select(MiniDiscord.Registry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  def init(state), do: {:ok, state}

  def handle_call({:rejoindre, pid}, _from, state) do

    Process.monitor(pid)

    clients =
      if pid in state.clients do
        state.clients
      else
        [pid | state.clients]
      end

    Enum.each(state.historique, fn msg ->
      send(pid, {:message, msg})
    end)

    {:reply, :ok, %{state | clients: clients}}
  end

  def handle_call({:quitter, pid}, _from, state) do
    clients = Enum.reject(state.clients, fn client -> client == pid end)

    {:reply, :ok, %{state | clients: clients}}
  end

  def handle_cast({:broadcast, msg}, state) do
    historique =
      state.historique
      |> Kernel.++([msg])
      |> Enum.take(-10)

    Enum.each(state.clients, fn pid ->
      send(pid, {:message, msg})
    end)

    {:noreply, %{state | historique: historique}}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    clients = Enum.reject(state.clients, fn client -> client == pid end)

    {:noreply, %{state | clients: clients}}
  end

  defp via(name), do: {:via, Registry, {MiniDiscord.Registry, name}}
end
