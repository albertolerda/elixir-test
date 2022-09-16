defmodule HttpClientServer do
  use Application

  @impl true
  def start(_type, _args) do
    {:ok, _} = ConnectionProcess.start_link({:https, "swarm0.dyne.org", 20001}, Zenswarm0)
    {:ok, _} = ConnectionProcess.start_link({:https, "swarm1.dyne.org", 20001}, Zenswarm1)
    {:ok, _} = ConnectionProcess.start_link({:https, "apiroom.net", 443}, Apiroom)
    {:ok, self()}
  end
end
