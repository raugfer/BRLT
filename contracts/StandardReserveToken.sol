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

// Standard implementation of the TetherToken interface
pragma solidity 0.4.15;

import "./ReserveToken.sol";
import "./StandardToken.sol";

contract StandardReserveToken is ReserveToken, StandardToken
{
	address exchange;

	function init(address _exchange) public returns (bool _success)
	{
		require(exchange == 0);
		exchange = _exchange;
		return true;
	}

	function mint(address _to, uint256 _value) payable public returns (bool _success)
	{
		require(msg.sender == exchange);
		uint256 _amount = msg.value;
		require(_amount > 0);
		require(supply + _value > supply);
		assert(balances[_to] + _value > balances[_to]);
		supply += _value;
		balances[_to] += _value;
		Mint(_to, _value, _amount);
		return true;
	}

	function burn(address _from, uint256 _value, uint256 _amount) public returns (bool _success)
	{
		require(msg.sender == exchange);
		require(_value > 0);
		require(_amount > 0);
		require(balances[_from] >= _value);
		assert(supply >= _value);
		balances[_from] -= _value;
		supply -= _value;
		_from.transfer(_amount);
		Burn(_from, _value, _amount);
		return true;
	}
}

