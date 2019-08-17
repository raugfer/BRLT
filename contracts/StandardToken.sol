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

// Standard implementation of the ERC20 token
pragma solidity 0.4.17;

import "./Token.sol";

contract StandardToken is Token
{
	uint256 supply;
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;

	function totalSupply() public view returns (uint256 _totalSupply)
	{
		return supply;
	}

	function balanceOf(address _owner) public view returns (uint256 _balance)
	{
		return balances[_owner];
	}

	function transfer(address _to, uint256 _value) public returns (bool _success)
	{
		require(msg.data.length >= 68); // fix for short address attack
		address _from = msg.sender;
		require(_value > 0);
		require(balances[_from] >= _value);
		assert(balances[_to] + _value > balances[_to]);
		balances[_from] -= _value;
		balances[_to] += _value;
		Transfer(_from, _to, _value);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success)
	{
		address _spender = msg.sender;
		require(_value > 0);
		require(balances[_from] >= _value);
		require(allowed[_from][_spender] >= _value);
		assert(balances[_to] + _value > balances[_to]);
		balances[_from] -= _value;
		allowed[_from][_spender] -= _value;
		balances[_to] += _value;
		Transfer(_from, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_value >= 0);
		allowed[_owner][_spender] = _value;
		Approval(_owner, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public view returns (uint256 _remaining)
	{
		return allowed[_owner][_spender];
	}
}
