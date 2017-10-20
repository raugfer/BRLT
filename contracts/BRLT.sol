// Concrete instance of the StandardReserveToken: the BRLT Token
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

