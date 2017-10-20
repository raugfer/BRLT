// Standard implementation of the ERC20 token
pragma solidity 0.4.15;

import "./Token.sol";

contract StandardToken is Token
{
	uint256 supply;
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;

	function totalSupply() public constant returns (uint256 _totalSupply)
	{
		return supply;
	}

	function balanceOf(address _owner) public constant returns (uint256 balance)
	{
		return balances[_owner];
	}

	function transfer(address _to, uint256 _value) public returns (bool success)
	{
		address _from = msg.sender;
		require(_value > 0);
		require(balances[_from] >= _value);
		assert(balances[_to] + _value > balances[_to]);
		balances[_from] -= _value;
		balances[_to] += _value;
		Transfer(_from, _to, _value);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
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

	function approve(address _spender, uint256 _value) public returns (bool success)
	{
		address _owner = msg.sender;
		allowed[_owner][_spender] = _value;
		Approval(_owner, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public constant returns (uint256 remaining)
	{
		return allowed[_owner][_spender];
	}
}

