# brlt

### A Spot Market in a Nutshell

In this section we will provide a simplified description of a spot market that
is the basis for the ideas presented in this document.

#### Market Structure

A spot market is composed of the following items:

* A _base asset_ that is being negotiated
* A _quote asset_ that is used to price the base asset, and also provided in exchange for it
* A set of traders carrying their own balances in both of these assets
* An _orderbook_ consisting of a set of orders partitioned in two:
  * _buy orders_ (or _bids_), listed in the _buy side_
  * _sell orders_ (or _asks_), listed in the _sell side_

Each order have basically three attributes:

* A _side_, either _buy_ or _sell_
* A _unit price_, or simply _price_, provided in the quote asset
* An _amount_, also refered to as _quantity_, provided in the base asset

The set of buy orders is organized descendently by price in the buy side.
The first order in the buy side is the order with the greatest price,
that is the best offer to acquire the base asset, known as _best buy order_.

Converselly, the set of sell orders is organized ascendently by price in
the sell side. The first order in the sell side is the order with the least
price, that is the best offer to hand over the base asset, known
as _best sell order_.

At all times, the best buy order price is less than the best sell order price.

Orders with the same price can be grouped together into a single entry in the
orderbook for their combined amount.

#### Market Mechanics

A trader can perform one of two atomic operations in the market:

* _place order_
* _cancel order_

In order to place a buy order in the orderbook, a trader needs to provide the
exact amount of the quote asset to cover for the total order price, which
corresponds to the order unit price multiplied by the order amount.

Converselly, in order to place a sell order in the orderbook, a trader needs
to provide the exact amount of the base asset. 

The amount deducted from the trade's balance upon placing an order is kept in
the custody of the _market owner_ (also refered to as the _market controller_).

All orders sitting in the orderbook are wating for _execution_ which is the act
of performing a _trade_.

A trade happens when a buy (or sell) order of price superior (or inferior)
to the best sell (buy) order in placed in the orderbook. When that happens,
both orders are executed and the associated amounts held in custody are swaped
and credited to their respective trader's balance.

Orders that wait for execution are refered to as _passive_ orders.

Orders that come into the orderbook and execute immediatly are refered to as _active_ orders.

When the active vs passive order amounts do not match fully, the execution is
partial. The amounts are traded proportionally and a remainder of one of the orders
is left in the orderbook.

In order to preserve _fairness_, passive orders of the same price are executed
in a FIFO (first-in, first-out) fashion, that is, older orders have higher priority
over younger ones.

At any time a trader can cancel his orders removing the entry from the orderbook
and receiving back the associated amount held in custody.

#### A Market Example

To materialize a simple example of a spot market let us assume that the base
asset is beer bottles and the quote asset is cash.

The orderbook would be a list of buy and sell orders where each order represents
a price for a bottle of beer and the number of bottles required or available
at that price.

Behind each order there is a trader that would have entered the market providing
either a number of bottles under his possession as a sell order; or an amount
of cash enough to buy a given number of bottles at the given price as a buy order.

Whenever buy and sell prices match, the buyer and the seller perform the trade
by exchanging the cash for the goods.

#### Market Freedom and Fairness

The spot market described above has two notable features, freedom and fairness.

Any trader, at any time, can operate in the orderbook without constraints of
price or imposed penalties. Therefore the market self-regulates freely
according to supply and demand yielded by competition.

We, of course, assume that traders will operate independently and
that the volume negotiated collectively in the market is significantly larger
that the volumes available for each trader to operate individually.

The market owner must be unbiased. The orderbook mechanics, and the custody
of assets held from passive orders, could make a good case for implementing
the market owner as a decentralized smart contract.

### A Self-Stabilizing Reserve Market

In this section we define the basic concept of a _self-stabilizing reserve market_
as an extension of the spot market.

#### The Reserve in the Market

For the context of this presentation, the _reserve_ is the amount of the base asset
maintained by the market owner (a benevolent brother) in order to control supply
and demand to influence the movement of its price.

The reserve _index price_ is the average price kept by the market owner that
reflects the exact investment, in terms of the quote currency, carried out
to maintain the reserve.

As we assume that the market owner builds the reserve simply by using regular
buy or sell orders, every order execution must modify the reserve amount and
its index price accordingly to capture in fidelity the underlying investment.

Let us look into growing the reserve. Assume that the reserve is currently `R`
and that the index price is `I`. If a buy order, placed by the market owner,
of base amount `B` executes at price `P`, the new reserve `R'` and its
index price `I'` will be

    R' = R + B
    I' = (RI + BP) / (R + B)

It is easy to deduce from the equation above that

    if P = I then P = I' = I
    if P < I then P < I' < I
    if P > I then P > I' > I

assuming that the reserve prior to the operation is not zero (`R > 0`). If the
reserve is zero (`R = 0` and `I` undefined) we always have `R = B` and `I' = P`.

How about shrinking the reserve? Assume that the reserve is currently `R`
and that the index price is `I`. If a sell order, placed by the market owner,
of base amount `B` executeds at price `P`, the new reserve `R'` and its
index price `I'` will be

    R' = R - B
    I' = (RI - BP) / (R - B)

It is easy to deduce from the equation above that

    if P = I then P = I = I'
    if P < I then P < I < I'
    if P > I then P > I > I'

assuming that the reserve prior to the operation is greater than the sell order
amount (`R > B`) . If the reserve equals the sell order amount (`R = B`)
we always have `R = 0` and `I'` undefined .

As can be observed, by placing buy orders, the market owner will aways move the
index price towards the market price (the price in which the order was executed).

However, by placing sell orders, there are two scenarios:

1. If the market price is less than the index price, the index price increases which means that the reserve has lost value
2. If the market price is greater than the index price, the index price decreases which means that the reserve has gained value

As a parenthesis, one can apply the same principles described above using the
quote asset as underlying reserve (`V` where `V = RI`). This would yield the following equations:

For growing the reserve

    V' = V + BP
    I' = (V + BP) / (V/I + B)

For shrinking the reserve

    V' = V - BP
    I' = (V - BP) / (V/I - B)

If we go back to our concrete example of a market of to buy and sell beer
bottles, a reserve would be a number of beer bottles under the market owner
custody. In order to acquire the reserve, the market owner would have put his
own buy orders at diferent moments and prices and kept track of the average
beer bottle price under his possession.

With the reserve in place, the market owner can influence the market in any way
he desires, buying and selling at strategic times. His only limitation is that,
for that, he would have to have enough cash to build the reserve.

Moreover, at all times, the market owner would have to pay close attention to his
sell orders. They cannot have prices below the index price, otherwise he would
be losing money. Clearly, if the beer market price falls below the index price,
he would have to wait or acquire more reserve until this scenario changes.

The market owner's role here would not be much diferent from a regular trader's one.
Except that we assume that the market owner is much larger than everybody else
and his motivation is to keep the health of the market rather than financial gains.

#### Self-Stabilization

The core idea behind _self-stabilization_ is straightforward:

* If demand is greater than supply, we increase the supply
* If supply is greater than demand, we decrease the supply

this is a simple and common strategy adopted by central banks to stabilize
currencies.

A savvy market owner could use a reserve to manage supply and demand to try to
stabilize the base assets price just like a central bank would. But there are
challenges:

* The market owner does not have control over the quote currency and would need
to have a lot of it to invest in a reserve


In our context, in order to achieve self-stabilization, we assume that the
market owner is solely responsible for minting and burning the quote asset,
using for that a variable amount of the base asset as reserve.

