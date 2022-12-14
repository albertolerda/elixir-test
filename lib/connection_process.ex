defmodule ConnectionProcess do
  use GenServer

  require Logger

  defstruct [:conn, requests: %{}]

  def start_link({scheme, host, port}, name) do
    GenServer.start_link(__MODULE__, {scheme, host, port}, name: name)
  end

  def request(name, {method, path, headers, body}) do
    GenServer.call(name, {:request, method, path, headers, body})
  end

  ## Callbacks

  @impl true
  def init({scheme, host, port}) do
    case Mint.HTTP.connect(scheme, host, port) do
      {:ok, conn} ->
        state = %__MODULE__{conn: conn}
        {:ok, state}

      {:error, reason} ->
        {:stop, Exception.message(reason)}
    end
  end

  @impl true
  def handle_call({:request, method, path, headers, body}, from, state) do
    # In both the successful case and the error case, we make sure to update the connection
    # struct in the state since the connection is an immutable data structure.
    case Mint.HTTP.request(state.conn, method, path, headers, body) do
      {:ok, conn, request_ref} ->
        state = put_in(state.conn, conn)
        # We store the caller this request belongs to and an empty map as the response.
        # The map will be filled with status code, headers, and so on.
        state = put_in(state.requests[request_ref], %{from: from, response: %{}})
        {:noreply, state}

      {:error, conn, reason} ->
        state = put_in(state.conn, conn)
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_info(message, state) do
    # We should handle the error case here as well, but we're omitting it for brevity.
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        _ = Logger.error(fn -> "Received unknown message: " <> inspect(message) end)
        {:noreply, state}

      {:ok, conn, responses} ->
        state = put_in(state.conn, conn)
        state = Enum.reduce(responses, state, &process_response/2)
        {:noreply, state}
      {:error, conn, reason, responses} ->
        reason = Exception.message(reason)
        state = put_in(state.conn, conn)
        # Send a response to all the succesful request
        state = Enum.reduce(responses, state, &process_response/2)

        # The remaining are failed
        Enum.map(state.requests, fn {_ref, %{response: _response, from: from}} ->
          GenServer.reply(from, {:error, reason}) end)

        {:noreply, state}
    end
  end


  defp process_response({:status, request_ref, status}, state) do
    put_in(state.requests[request_ref].response[:status], status)
  end

  defp process_response({:headers, request_ref, headers}, state) do
    put_in(state.requests[request_ref].response[:headers], headers)
  end

  defp process_response({:data, request_ref, new_data}, state) do
    update_in(state.requests[request_ref].response[:data], fn data -> [(data || ""), new_data] end)
  end

  defp process_response({:error, request_ref, error}, state) do
    update_in(state.requests[request_ref].response[:error], error)
  end

  defp process_response({:done, request_ref}, state) do
    state = update_in(state.requests[request_ref].response[:data], &IO.iodata_to_binary/1)
    {%{response: response, from: from}, state} = pop_in(state.requests[request_ref])
    GenServer.reply(from, {:ok, response})
    state
  end
end
