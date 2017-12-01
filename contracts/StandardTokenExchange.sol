// Standard implementation of a simple ERC 20 Token exchange
pragma solidity ^0.4.15;

import "./Token.sol";
import "./TokenExchange.sol";

contract StandardTokenExchange is TokenExchange
{
	struct Order
	{
		uint32 above;
		address owner;
		uint256 amount;
		uint256 value;
		uint32 below;
	}

	uint8 constant types = 2;

	address token;
	uint32 asks;
	uint32 bids;
	uint32 serial;
	mapping (uint32 => Order) orders;

	function StandardTokenExchange(address _token) public
	{
		token = _token;
	}

	function buyQuote(uint256 _value) public constant returns (uint256 _amount)
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
				assert((_value * _order.amount) / _order.amount == _value);
				uint256 _prorated_amount = (_value * _order.amount) / _order.value;
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
		if (_value > 0) revert();
		return _amount;
	}

	function sellQuote(uint256 _amount) public constant returns (uint256 _value)
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
				assert((_amount * _order.value) / _order.value == _amount);
				uint256 _prorated_value = (_amount * _order.value) / _order.amount;
				_amount = 0;
				assert(_value + _prorated_value > _value);
				_value += _prorated_value;
				break;
			}
			_amount -= _order.amount;
			assert(_value + _order.value > _value);
			_value += _order.value;
			_bid = _order.below;
		}
		if (_amount > 0) revert();
		return _value;
	}

	function buy() payable public returns (bool _success)
	{
		address _owner = msg.sender;
		uint256 _value = msg.value;
		uint32 _ask = asks;
		while (_ask > 0)
		{
			Order storage _order = orders[_ask];
			assert(_order.owner > 0);
			if (_order.value > _value)
			{
				if (_value > 0)
				{
					assert((_value * _order.amount) / _order.amount == _value);
					uint256 _amount = (_value * _order.amount) / _order.value;
					if (!Token(token).transfer(_owner, _amount)) revert();
					_order.owner.transfer(_value);
					Buy(_owner, _value, _amount, _order.owner, _ask, false);
					_order.amount -= _amount;
					_order.value -= _value;
					_value = 0;
				}
				_order.below = 0;
				break;
			}
			if (!Token(token).transfer(_owner, _order.amount)) revert();
			_order.owner.transfer(_order.value);
			Buy(_owner, _order.value, _order.amount, _order.owner, _ask, true);
			_value -= _order.value;
			uint32 _id = _ask;
			_ask = _order.above;
			delete orders[_id];
		}
		if (_value > 0) revert();
		asks = _ask;
		return true;
	}

	function sell(uint256 _amount) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_amount > 0);
		uint32 _bid = bids;
		while (_bid > 0)
		{
			Order storage _order = orders[_bid];
			assert(_order.owner > 0);
			if (_order.amount > _amount)
			{
				if (_amount > 0)
				{
					assert((_amount * _order.value) / _order.value == _amount);
					uint256 _value = (_amount * _order.value) / _order.amount;
					if (!Token(token).transferFrom(_owner, _order.owner, _amount)) revert();
					_owner.transfer(_value);
					Sell(_owner, _amount, _value, _order.owner, _bid, false);
					_order.amount -= _amount;
					_order.value -= _value;
					_amount = 0;
				}
				_order.above = 0;
				break;
			}
			if (!Token(token).transferFrom(_owner, _order.owner, _order.amount)) revert();
			_owner.transfer(_order.value);
			Sell(_owner, _order.amount, _order.value, _order.owner, _bid, true);
			_amount -= _order.amount;
			uint32 _id = _bid;
			_bid = _order.below;
			delete orders[_id];
		}
		if (_amount > 0) revert();
		bids = _bid;
		return true;
	}

	function placeBuyOrder(uint256 _amount) payable public returns (uint32 _id)
	{
		address _owner = msg.sender;
		uint256 _value = msg.value;
		require(_amount > 0);
		if (asks > 0)
		{
			Order storage _order = orders[asks];
			assert(_order.owner > 0);
			assert((_amount * _order.value) / _order.value == _amount);
			assert((_value * _order.amount) / _order.amount == _value);
			require(_order.value * _amount > _value * _order.amount);
		}
		uint32 _above = 0;
		uint32 _bid = bids;
		while (_bid > 0)
		{
			_order = orders[_bid];
			assert((_amount * _order.value) / _order.value == _amount);
			assert((_value * _order.amount) / _order.amount == _value);
			if (_order.value * _amount < _value * _order.amount) break;
			_above = _bid;
			_bid = _order.below;
		}
		_id = serial;
		serial += types;
		while (_id == 0 || orders[_id].owner > 0)
		{
			_id = serial;
			serial += types;
		}
		orders[_id] = Order(_above, _owner, _amount, _value, _bid);
		if (_above > 0) orders[_above].below = _id; else bids = _id;
		if (_bid > 0) orders[_bid].above = _id;
		PlaceBuyOrder(_owner, _amount, _value, _id);
		return _id;
	}

	function placeSellOrder(uint256 _amount, uint256 _value) public returns (uint32 _id)
	{
		address _owner = msg.sender;
		require(_amount > 0);
		require(_value > 0);
		if (bids > 0)
		{
			Order storage _order = orders[bids];
			assert(_order.owner > 0);
			assert((_amount * _order.value) / _order.value == _amount);
			assert((_value * _order.amount) / _order.amount == _value);
			require(_order.value * _amount < _value * _order.amount);
		}
		uint32 _below = 0;
		uint32 _ask = asks;
		while (_ask > 0)
		{
			_order = orders[_ask];
			assert((_amount * _order.value) / _order.value == _amount);
			assert((_value * _order.amount) / _order.amount == _value);
			if (_order.value * _amount > _value * _order.amount) break;
			_below = _ask;
			_ask = _order.above;
		}
		if (!Token(token).transferFrom(_owner, this, _amount)) revert();
		_id = serial + 1;
		serial += types;
		while (_id == 0 || orders[_id].owner > 0)
		{
			_id = serial + 1;
			serial += types;
		}
		orders[_id] = Order(_ask, _owner, _amount, _value, _below);
		if (_ask > 0) orders[_ask].below = _id;
		if (_below > 0) orders[_below].above = _id; else asks = _id;
		PlaceSellOrder(_owner, _amount, _value, _id);
		return _id;
	}

	function cancelBuyOrder(uint32 _id) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_id > 0);
		require(_id % types == 0);
		Order storage _order = orders[_id];
		require(_order.owner == _owner);
		if (_order.above > 0) orders[_order.above].below = _order.below; else bids = _order.below;
		if (_order.below > 0) orders[_order.below].above = _order.above;
		_owner.transfer(_order.value);
		CancelBuyOrder(_owner, _order.value, _order.amount, _id);
		delete orders[_id];
		return true;
	}

	function cancelSellOrder(uint32 _id) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_id > 0);
		require(_id % types == 1);
		Order storage _order = orders[_id];
		require(_order.owner == _owner);
		if (_order.above > 0) orders[_order.above].below = _order.below;
		if (_order.below > 0) orders[_order.below].above = _order.above; else asks = _order.above;
		if (!Token(token).transfer(_owner, _order.amount)) revert();
		CancelSellOrder(_owner, _order.amount, _order.value, _id);
		delete orders[_id];
		return true;
	}
}

