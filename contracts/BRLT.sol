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

// Concrete instance of the StandardTetherToken: the BRLT
pragma solidity 0.4.15;

import "./StandardReserveToken.sol";

contract BRLT is StandardReserveToken
{
	function name() public constant returns (string _name)
	{
		return "Brazilian Real Token";
	}

	function symbol() public constant returns (string _symbol)
	{
		return "BRLT";
	}

	function decimals() public constant returns (uint8 _decimals)
	{
		return 2;
	}
}

