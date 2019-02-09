# brlt

### A Spot Market in a Nutshell

In this section we will provide a simplified description of a spot market that
is the basis for the ideas presented in this document.

#### Market Structure

A spot market is composed of the following items:

* A _base asset_ that is being negotiated
* A _quote asset_ that is used to price the base asset, and also provided in exchange for it
* A set of traders carrying their own balances in both of there assets
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
the custody of the _market owner_.

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

#### Market Freedom and Fairness

The spot market described above has two notable features, freedom and fairness.

Any trader, at any time, can operate in the orderbook without constraints of
price or imposed penalties. Therefore the market self-regulates freely
according to supply and demand.

We, of course, assume that traders will operate independently and
that the volume negotiated collectively in the market is significantly larger
that the volumes available for each trader to operate individually.

The market owner must be unbiased. The orderbook mechanichs and custody
of assets held from passive orders could be implemented by a decentralized
smart contract.

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
reserve is zero (`R = 0` and `I` undefined) we always have `I' = P` and `R = B`.

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
we always have `I'` undefined and `R = 0`.

As can be observed, by placing buy orders, the market owner will aways move the
index price towards the market price (the price in which the order was executed).

However, by placing sell orders, there are two scenarios:

1. If the market price is less than the index price, the index price increases which means that the reserve has lost value
2. If the market price is greater than the index price, the index price decreases which means that the reserve has gained value

