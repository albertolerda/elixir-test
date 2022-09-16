defmodule ConnectionProcessTest do
  use ExUnit.Case,async: true
  doctest ConnectionProcess

  test "send a request" do
    # :timer.sleep(10000)
    ConnectionProcess.request(Zenswarm, {"GET", "/api", [], []}) |> IO.inspect()
  end
  test "send another request after a lot of time" do
    # :timer.sleep(10000)
    ConnectionProcess.request(Zenswarm, {"GET", "/api", [], []}) |> IO.inspect()
  end

end
