/*
 * BRLT, the Brazilian Real Token project
 * Copyright (C) 2017 <rodrigo.ferreira@aya.yale.edu>
 *
 * This file is part of BRLT.
 *
 * BRLT is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * BRLT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with BRLT.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Standard implementation of a simple decentralized ERC 20 Token exchange
// extended with the capacity of minting and burning
pragma solidity ^0.4.15;

import "./ReserveToken.sol";
import "./ReserveExchange.sol";
import "./StandardExchange.sol";

contract StandardReserveExchange is ReserveExchange, StandardExchange
{
	mapping (uint32 => uint256) amounts;

	function placeMintOrder(uint256 _profit) payable public returns (uint32 _id)
	{
		address _owner = msg.sender;
		uint256 _amount = msg.value;
		require(_amount > 0);
		require(_profit > 0);
		assert(_amount + _profit > _amount);
		uint256 _sell_amount = _amount + _profit;
		uint256 _value = quoteBuyGive(_amount);
		require(ReserveToken(token).mint.value(_amount)(_owner, _value));
		_id = placeSellOrder(_value, _sell_amount);
		assert(amounts[_id] == 0);
		amounts[_id] = _amount;
		return _id;
	}

	function placeBurnOrder(uint256 _profit) payable public returns (uint32 _id)
	{
		uint256 _amount = msg.value;
		require(_amount > 0);
		require(_profit > 0);
		assert(_amount + _profit > _amount);
		uint256 _burn_amount = _amount + _profit;
		uint256 _supply;
		uint256 _balance;
		(_supply, _balance) = ReserveToken(token).rate();
		require(_balance > 0);
		assert((_supply * _burn_amount) / _burn_amount == _supply);
		uint256 _value = (_supply * _burn_amount) / _balance;
		_id = this.placeBuyOrder.value(_amount)(_value);
		assert(amounts[_id] == 0);
		amounts[_id] = _burn_amount;
		return _id;
	}

	function performBuy(address _buyer, address _seller, uint256 _value, uint256 _amount, uint32 _id, bool _complete) internal returns (bool _success)
	{
		delete amounts[_id];
		require(super.performBuy(_buyer, _seller, _value, _amount, _id, _complete));
		return true;
	}

	function performSell(address _buyer, address _seller, uint256 _value, uint256 _amount, uint32 _id, bool _complete) internal returns (bool _success)
	{
		if (_complete)
		{
			uint256 _burn_amount = amounts[_id];
			delete amounts[_id];
			if (_burn_amount > 0) require(ReserveToken(token).burn(this, _value, _burn_amount));
		}
		require(super.performSell(_buyer, _seller, _value, _amount, _id, _complete));
		return true;
	}

	function cancelBuyOrder(uint32 _id) public returns (bool _success)
	{
		delete amounts[_id];
		require(super.cancelBuyOrder(_id));
		return true;
	}

	function cancelSellOrder(uint32 _id) public returns (bool _success)
	{
		address _owner = msg.sender;
		uint256 _value = orders[_id].value;
		uint256 _amount = amounts[_id];
		delete amounts[_id];
		require(super.cancelSellOrder(_id));
		if (_amount > 0) require(ReserveToken(token).burn(_owner, _value, _amount));
		return true;
	}
}

