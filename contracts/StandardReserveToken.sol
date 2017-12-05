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

// Standard implementation of the ReserveToken interface
pragma solidity 0.4.15;

import "./ReserveToken.sol";
import "./StandardToken.sol";

contract StandardReserveToken is ReserveToken, StandardToken
{
	address authority;
	mapping (address => uint256) limits;
	mapping (address => uint256) reserves;
	mapping (address => address) targets;

	function StandardReserveToken() public
	{
		authority = msg.sender;
	}

	function custodianLimit(address _custodian) public constant returns (uint256 _custodianLimit)
	{
		return limits[_custodian];
	}

	function custodianReserve(address _custodian) public constant returns (uint256 _custodianReserve)
	{
		return reserves[_custodian];
	}

	function mint(address _to, uint256 _value, string _meta) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(supply + _value > supply);
		assert(reserves[_owner] + _value > reserves[_owner]);
		assert(balances[_to] + _value > balances[_to]);
		require(reserves[_owner] + _value <= limits[_owner]);
		supply += _value;
		reserves[_owner] += _value;
		balances[_to] += _value;
		Mint(_owner, _to, _value, _meta);
		Transfer(0, _to, _value);
		return true;
	}

	function burn(address _from, uint256 _value, string _meta) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_value > 0);
		require(balances[_from] >= _value);
		require(reserves[_owner] >= _value);
		assert(supply >= _value);
		balances[_from] -= _value;
		reserves[_owner] -= _value;
		supply -= _value;
		Transfer(_from, 0, _value);
		Burn(_owner, _from, _value, _meta);
		return true;
	}

	function transferCustody(address _custodian) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_custodian != 0);
		require(limits[_custodian] == 0);
		require(reserves[_custodian] == 0);
		require(targets[_custodian] == 0);
		reserves[_custodian] = reserves[_owner];
		limits[_owner] = 0;
		reserves[_owner] = 0;
		targets[_owner] = _custodian;
		return true;
	}

	function targetOf(address _custodian) public constant returns (address _targetOf)
	{
		while (targets[_custodian] != 0) _custodian = targets[_custodian];
		return _custodian;
	}

	function grantCustody(address _custodian, uint256 _limit) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_owner == authority);
		require(_custodian != 0);
		require(targets[_custodian] == 0);
		limits[_custodian] = _limit;
		return true;
	}

	function transferAuthority(address _authority) public returns (bool _success)
	{
		address _owner = msg.sender;
		require(_owner == authority);
		authority = _authority;
		return true;
	}
}

