defmodule Runeforge.PlayerSocket do
  use Phoenix.Socket

  channel "lobby", Runeforge.LobbyChannel

  ## Channels
  # channel "room:*", Runeforge.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @max_age 2 * 7 * 24 * 60 * 60

  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "player socket", token, max_age: @max_age) do
      {:ok, player_id} ->
        player = Runeforge.Repo.get!(Runeforge.Player, player_id)
        {:ok, assign(socket, :current_player, player)}
      {:error, _reason} ->
        {:ok, socket}
    end
  end
  def connect(_params, _socket), do: :error

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Runeforge.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket) do
    case player = socket.assigns[:current_player] do
      nil -> nil
      player -> "player_socket:#{player.id}"
    end
  end
end
