defmodule Runeforge.BoardServer do
  use GenServer

  alias Runeforge.Repo
  alias Runeforge.Character

  # Client API

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  # def new_bid(bid_params) do
  #   GenServer.call(:auction_server, {:new_bid, bid_params})
  # end

  # Server implementation

  def init([]) do
    characters = Repo.all(Character)
    {:ok, %{characters: characters}}
  end

  #####
  # Interface
  #####

  def get() do
    GenServer.call(:board_server, {:get})
  end

  # def handle_call({:new_bid, bid_params}, _from, bids) do
  #   changeset = Bid.changeset(%Bid{}, bid_params)
  #   case Repo.insert(changeset) do
  #     {:ok, bid} ->
  #       Auctioneer.Endpoint.broadcast! "bids:max", "change", Auctioneer.BidView.render("show.json", %{bid: bid})
  #       {:reply, {:ok, bid}, [bid | bids]}
  #     {:error, changeset} ->
  #       {:reply, {:error, changeset}, bids}
  #   end
  # end

  def handle_call({:get}, _from, map = %{characters: []}) do
    {:reply, {:ok, []}, map}
  end
  def handle_call({:get}, _from, map = %{characters: characters}) do
    [head | _ ] = characters
    {:reply, {:ok, head}, map}
  end

end
