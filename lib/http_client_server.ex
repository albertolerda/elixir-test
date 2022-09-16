defmodule HttpClientServer do
  use Application

  @impl true
  def start(_type, _args) do
    {:ok, _} = ConnectionProcess.start_link({:https, "fcos.interfacer.dyne.org", 443}, Zenswarm)
  end
end
