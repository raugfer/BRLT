// Standard implementation of the PeggedToken interface
pragma solidity 0.4.15;

import "./PeggedToken.sol";
import "./StandardToken.sol";

contract StandardPeggedToken is PeggedToken, StandardToken
{
	address authority;
	uint256 currentPrice;

	function PeggedToken() public
	{
		authority = msg.sender;
	}

	function mintPrice() public constant returns (uint256 _mintPrice)
	{
		require(currentPrice > 0);
		return currentPrice;
	}

	function burnPrice() public constant returns (uint256 _burnPrice)
	{
		require(currentPrice > 0);
		if (supply > 0)
		{
			uint256 _reservePrice = this.balance / supply;
			if (_reservePrice < currentPrice) return _reservePrice;
		}
		return currentPrice;
	}

	function mint() payable public returns (bool success)
	{
		address _to = msg.sender;
		uint256 _amount = msg.value;
		uint256 _value = _amount / mintPrice();
		require(supply + _value > supply);
		assert(balances[_to] + _value > balances[_to]);
		supply += _value;
		balances[_to] += _value;
		Mint(_to, _value);
		Transfer(0, _to, _value);
		return true;
	}

	function burn(uint256 _value) public returns (bool success)
	{
		address _from = msg.sender;
		require(_value > 0);
		require(balances[_from] >= _value);
		assert(supply >= _value);
		uint256 _amount = _value * burnPrice();
		_from.transfer(_amount);
		balances[_from] -= _value;
		supply -= _value;
		Transfer(_from, 0, _value);
		Burn(_from, _value);
		return true;
	}

	function updatePrice(uint256 _currentPrice) public returns (bool success)
	{
		address _owner = msg.sender;
		require(_owner == authority);
		require(_currentPrice > 0);
		currentPrice = _currentPrice;
		return true;
	}

	function transferAuthority(address _authority) public returns (bool success)
	{
		address _owner = msg.sender;
		require(_owner == authority);
		authority = _authority;
		return true;
	}
}

