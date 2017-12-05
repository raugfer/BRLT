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

// Interface for an extension of the the ERC 20 Token standard
// that allows for minting and burning coins
// Inspired by https://github.com/ethereum/EIPs/pull/621
// Assumes the custody of assets by the contract in ETH
pragma solidity 0.4.15;

import "./Token.sol";

contract ReserveToken is Token
{
	function mint(address _to, uint256 _value) payable public returns (bool _success);
	function burn(address _from, uint256 _value, uint256 _amount) public returns (bool _success);
	event Mint(address indexed _to, uint256 _value, uint256 _amount);
	event Burn(address indexed _from, uint256 _value, uint256 _amount);
}

