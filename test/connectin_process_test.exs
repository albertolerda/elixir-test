defmodule ConnectionProcessTest do
  use ExUnit.Case,async: true
  doctest ConnectionProcess

  setup_all %{} do
    :ok
  end

  test "send a request" do
    # :timer.sleep(10000);
    {:ok, result} = ConnectionProcess.request(Zenswarm0, {"GET", "/api/zenswarm-oracle-get-timestamp", [], []})
    assert(result.status == 200)
  end
  test "send a request to a non existing url" do
    {:error, reason} = ConnectionProcess.start_link({:https, "swarm42.dyne.org", 20001}, Swarm42)
    assert(reason == "non-existing domain")
  end

end
