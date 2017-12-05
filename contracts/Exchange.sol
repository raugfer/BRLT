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

// Interface for a simple ERC 20 Token exchange
pragma solidity ^0.4.15;

contract Exchange
{
	function bid(uint32 _depth) public constant returns (uint256 _value, uint256 _amount);
	function ask(uint32 _depth) public constant returns (uint256 _value, uint256 _amount);
	function quoteBuyGive(uint256 _amount) public constant returns (uint256 _value);
	function quoteSellTake(uint256 _amount) public constant returns (uint256 _value);
	function quoteBuyTake(uint256 _value) public constant returns (uint256 _amount);
	function quoteSellGive(uint256 _value) public constant returns (uint256 _amount);
	function buy() payable public returns (bool _success);
	function sell(uint256 _value) public returns (bool _success);
	function placeBuyOrder(uint256 _value) payable public returns (uint32 _id);
	function placeSellOrder(uint256 _value, uint256 _amount) public returns (uint32 _id);
	function order(uint32 _id) public constant returns (uint256 _value, uint256 _amount);
	function cancelBuyOrder(uint32 _id) public returns (bool _success);
	function cancelSellOrder(uint32 _id) public returns (bool _success);

	event Buy(address indexed _buyer, address indexed _seller, uint256 _value, uint256 _amount, uint32 _id, bool _complete);
	event Sell(address indexed _buyer, address indexed _seller, uint256 _value, uint256 _amount, uint32 _id, bool _complete);
	event PlaceBuyOrder(address indexed _owner, uint256 _value, uint256 _amount, uint32 _id);
	event PlaceSellOrder(address indexed _owner, uint256 _value, uint256 _amount, uint32 _id);
	event CancelBuyOrder(address indexed _owner, uint256 _value, uint256 _amount, uint32 _id);
	event CancelSellOrder(address indexed _owner, uint256 _value, uint256 _amount, uint32 _id);
}

