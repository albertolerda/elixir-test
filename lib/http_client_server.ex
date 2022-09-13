defmodule HttpClientServer do
  use Application

  @impl true
  def start(_type, _args) do
    {:ok, _} = ConnectionProcess.start_link({:http, "65.109.11.42", 8000})
  end
end
