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

// Interface for the ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity 0.4.17;

contract Token
{
	// Optional
	// function name() public view returns (string _name);
	// function symbol() public view returns (string _symbol);
	// function decimals() public view returns (uint8 _decimals);
	function totalSupply() public view returns (uint256 _totalSupply);
	function balanceOf(address _owner) public view returns (uint256 _balance);
	function transfer(address _to, uint256 _value) public returns (bool _success);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success);
	function approve(address _spender, uint256 _value) public returns (bool _success);
	function allowance(address _owner, address _spender) public view returns (uint256 _remaining);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
