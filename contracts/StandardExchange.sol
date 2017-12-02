// Standard implementation of a simple ERC 20 Token exchange
pragma solidity ^0.4.15;

import "./Token.sol";
import "./Exchange.sol";

contract StandardExchange is Exchange
{
	struct Order
	{
		uint32 above;
		address owner;
		uint256 value;
		uint256 amount;
		uint32 below;
	}

	uint8 constant types = 2;

	address token;
	uint32 asks;
	uint32 bids;
	uint32 sequence;
	mapping (uint32 => Order) orders;

	function StandardExchange(address _token) public
	{
		require(_token > 0);
		token = _token;
	}

	function bid(uint32 _depth) public constant returns (uint256 _value, uint256 _amount)
	{
		uint32 _bid = bids;
		while (_bid > 0)
		{
			Order storage _order = orders[_bid];
			assert(_order.owner > 0);
			if (_depth == 0) return (_order.value, _order.amount);
			_depth--;
			_bid = _order.below;
		}
		return (0, 0);
	}

	function ask(uint32 _depth) public constant returns (uint256 _value, uint256 _amount)
	{
		uint32 _ask = asks;
		while (_ask > 0)
		{
			Order storage _order = orders[_ask];
			assert(_order.owner > 0);
			if (_depth == 0) return (_order.value, _order.amount);
			_depth--;
			_ask = _order.above;
		}
		return (0, 0);
	}

	function quoteBuyGive(uint256 _amount) public constant returns (uint256 _value)
	{
		require(_amount > 0);
		_value = 0;
		uint32 _ask = asks;
		while (_ask > 0)
		{
			Order storage _order = orders[_ask];
			assert(_order.owner > 0);
			if (_order.amount > _amount)
			{
				assert((_order.value * _amount) / _amount == _order.value);
				uint256 _prorated_value = (_order.value * _amount) / _order.amount;
				assert(_value + _prorated_value > _value);
				_value += _prorated_value;
				_amount = 0;
				break;
			}
			assert(_value + _order.value > _value);
			_value += _order.value;
			_amount -= _order.amount;
			_ask = _order.above;
		}
		require(_amount == 0);
		return _value;
	}

	function quoteSellTake(uint256 _amount) public constant returns (uint256 _value)
	{
		require(_amount > 0);
		_value = 0;
		uint32 _bid = bids;
		while (_bid > 0)
		{
			Order storage _order = orders[_bid];
			assert(_order.owner > 0);
			if (_order.amount > _amount)
			{
				assert((_order.value * _amount) / _amount == _order.value);
				uint256 _prorated_value = (_order.value * _amount) / _order.amount;
				assert(_value + _prorated_value > _value);
				_value += _prorated_value;
				_amount = 0;
				break;
			}
			assert(_value + _order.value > _value);
			_value += _order.value;
			_amount -= _order.amount;
			_bid = _order.below;
		}
		require(_amount == 0);
		return _value;
	}

	function quoteBuyTake(uint256 _value) public constant returns (uint256 _amount)
	{
		require(_value > 0);
		_amount = 0;
		uint32 _ask = asks;
		while (_ask > 0)
		{
			Order storage _order = orders[_ask];
			assert(_order.owner > 0);
			if (_order.value > _value)
			{
				assert((_order.amount * _value) / _value == _order.amount);
				uint256 _prorated_amount = (_order.amount * _value) / _order.value;
				assert(_amount + _prorated_amount > _amount);
				_amount += _prorated_amount;
				_value = 0;
				break;
			}
			assert(_amount + _order.amount > _amount);
			_amount += _order.amount;
			_value -= _order.value;
			_ask = _order.above;
		}
		require(_value == 0);
		return _amount;
	}

	function quoteSellGive(uint256 _value) public constant returns (uint256 _amount)
	{
		require(_value > 0);
		_amount = 0;
		uint32 _bid = bids;
		while (_bid > 0)
		{
			Order storage _order = orders[_bid];
			assert(_order.owner > 0);
			if (_order.value > _value)
			{
				assert((_order.amount * _value) / _value == _order.amount);
				uint256 _prorated_amount = (_order.amount * _value) / _order.value;
				assert(_amount + _prorated_amount > _amount);
				_amount += _prorated_amount;
				_value = 0;
				break;
			}
			assert(_amount + _order.amount > _amount);
			_amount += _order.amount;
			_value -= _order.value;
			_bid = _order.below;
		}
		require(_value == 0);
		return _amount;
	}

	function buy() payable public returns (bool _success)
	{
		address _owner = msg.sender;
		uint256 _amount = msg.value;
		require(_amount > 0);
		uint32 _ask = asks;
		while (_ask > 0)
		{
			Order storage _order = orders[_ask];
			assert(_order.owner > 0);
			if (_order.amount > _amount)
			{
				_order.below = 0;
				if (_amount > 0)
				{
					assert((_order.value * _amount) / _amount == _order.value);
					uint256 _value = (_order.value * _amount) / _order.amount;
					require(_value > 0);	// TODO fix limitation
					assert(_order.value > _value);
					_order.amount -= _amount;
					_order.value -= _value;
					_order.owner.transfer(_amount);
					require(Token(token).transfer(_owner, _value));
					Buy(_owner, _order.owner, _value, _amount, _ask, false);
					_amount = 0;
				}
				break;
			}
			asks = _order.above;
			address _order_owner = _order.owner;
			uint256 _order_value = _order.value;
			uint256 _order_amount = _order.amount;
			delete orders[_ask];
			_order.owner.transfer(_order_amount);
			require(Token(token).transfer(_owner, _order_value));
			Buy(_owner, _order_owner, _order_value, _order_amount, _ask, true);
			_amount -= _order_amount;
			_ask = asks;
		}
		require(_amount == 0);	// TODO fix limitation
		return true;
	}

	function sell(uint256 _value) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_value > 0);
		uint32 _bid = bids;
		while (_bid > 0)
		{
			Order storage _order = orders[_bid];
			assert(_order.owner > 0);
			if (_order.value > _value)
			{
				_order.above = 0;
				if (_value > 0)
				{
					assert((_order.amount * _value) / _value == _order.amount);
					uint256 _amount = (_order.amount * _value) / _order.value;
					require(_amount > 0);	// TODO fix limitation
					assert(_order.amount > _amount);
					_order.amount -= _amount;
					_order.value -= _value;
					_owner.transfer(_amount);
					require(Token(token).transferFrom(_owner, _order.owner, _value));
					Sell(_owner, _order.owner, _value, _amount, _bid, false);
					_value = 0;
				}
				break;
			}
			bids = _order.below;
			address _order_owner = _order.owner;
			uint256 _order_value = _order.value;
			uint256 _order_amount = _order.amount;
			delete orders[_bid];
			_owner.transfer(_order_amount);
			require(Token(token).transferFrom(_owner, _order_owner, _order_value));
			Sell(_owner, _order_owner, _order_value, _order_amount, _bid, true);
			_value -= _order_value;
			_bid = bids;
		}
		require(_value == 0);	// TODO fix limitation
		return true;
	}

	function placeBuyOrder(uint256 _value) payable public returns (uint32 _id)
	{
		address _owner = msg.sender;
		uint256 _amount = msg.value;
		require(_amount > 0);
		require(_value > 0);
		if (asks > 0)
		{
			Order storage _order = orders[asks];
			assert(_order.owner > 0);
			assert((_order.amount * _value) / _value == _order.amount);
			assert((_amount * _order.value) / _order.value == _amount);
			require(_order.amount * _value > _amount * _order.value);	// TODO fix limitation
		}
		uint32 _above = 0;
		uint32 _below = bids;
		while (_below > 0)
		{
			_order = orders[_below];
			assert(_order.owner > 0);
			assert((_order.amount * _value) / _value == _order.amount);
			assert((_amount * _order.value) / _order.value == _amount);
			if (_order.amount * _value < _amount * _order.value) break;
			_above = _below;
			_below = _order.below;
		}
		_id = sequence;
		sequence += types;
		while (_id == 0 || orders[_id].owner > 0)
		{
			_id = sequence;
			sequence += types;
		}
		orders[_id] = Order(_above, _owner, _value, _amount, _below);
		if (_above > 0) orders[_above].below = _id; else bids = _id;
		if (_below > 0) orders[_below].above = _id;
		PlaceBuyOrder(_owner, _value, _amount, _id);
		return _id;
	}

	function placeSellOrder(uint256 _value, uint256 _amount) public returns (uint32 _id)
	{
		address _owner = msg.sender;
		require(_value > 0);
		require(_amount > 0);
		if (bids > 0)
		{
			Order storage _order = orders[bids];
			assert(_order.owner > 0);
			assert((_order.amount * _value) / _value == _order.amount);
			assert((_amount * _order.value) / _order.value == _amount);
			require(_order.amount * _value < _amount * _order.value);	// TODO fix limitation
		}
		uint32 _below = 0;
		uint32 _above = asks;
		while (_above > 0)
		{
			_order = orders[_above];
			assert(_order.owner > 0);
			assert((_order.amount * _value) / _value == _order.amount);
			assert((_amount * _order.value) / _order.value == _amount);
			if (_order.amount * _value > _amount * _order.value) break;
			_below = _above;
			_above = _order.above;
		}
		_id = sequence + 1;
		sequence += types;
		while (_id == 0 || orders[_id].owner > 0)
		{
			_id = sequence + 1;
			sequence += types;
		}
		orders[_id] = Order(_above, _owner, _value, _amount, _below);
		if (_above > 0) orders[_above].below = _id;
		if (_below > 0) orders[_below].above = _id; else asks = _id;
		require(Token(token).transferFrom(_owner, this, _value));
		PlaceSellOrder(_owner, _value, _amount, _id);
		return _id;
	}

	function order(uint32 _id) public constant returns (uint256 _value, uint256 _amount)
	{
		address _owner = msg.sender;
		require(_id > 0);
		Order storage _order = orders[_id];
		require(_order.owner == _owner);
		_value = _order.value;
		_amount = _order.amount;
		return (_value, _amount);
	}

	function cancelBuyOrder(uint32 _id) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_id > 0);
		require(_id % types == 0);
		Order storage _order = orders[_id];
		require(_order.owner == _owner);
		uint256 _value = _order.value;
		uint256 _amount = _order.amount;
		if (_order.above > 0) orders[_order.above].below = _order.below; else bids = _order.below;
		if (_order.below > 0) orders[_order.below].above = _order.above;
		delete orders[_id];
		_owner.transfer(_amount);
		CancelBuyOrder(_owner, _value, _amount, _id);
		return true;
	}

	function cancelSellOrder(uint32 _id) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_id > 0);
		require(_id % types == 1);
		Order storage _order = orders[_id];
		require(_order.owner == _owner);
		uint256 _value = _order.value;
		uint256 _amount = _order.amount;
		if (_order.above > 0) orders[_order.above].below = _order.below;
		if (_order.below > 0) orders[_order.below].above = _order.above; else asks = _order.above;
		delete orders[_id];
		require(Token(token).transfer(_owner, _value));
		CancelSellOrder(_owner, _value, _amount, _id);
		return true;
	}
}

