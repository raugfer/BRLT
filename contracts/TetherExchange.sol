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
// extended with the capacity of minting and burning
pragma solidity ^0.4.15;

import "./Exchange.sol"

contract TetherExchange is Exchange
{
	function placeMintOrder(uint256 _profit) payable public returns (uint32 _id);
	function placeBurnOrder(uint256 _profit) payable public returns (uint32 _id);
}

