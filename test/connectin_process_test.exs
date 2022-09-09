defmodule ConnectionProcessTest do
  use ExUnit.Case,async: true
  doctest ConnectionProcess

  setup_all do
    {:ok, _} = ConnectionProcess.start_link({:http, "65.109.11.42", 8000})
    :ok
  end

  test "send a request" do
    ConnectionProcess.request("GET", "/api", [], []) |> IO.inspect()
  end
  test "send another request" do
    ConnectionProcess.request("GET", "/api", [], []) |> IO.inspect()
  end
end
