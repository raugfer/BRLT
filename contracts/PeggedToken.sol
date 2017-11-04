// Interface for an extension of the the ERC 20 Token standard
// that allows for minting and burning coins
// Inspired by https://github.com/ethereum/EIPs/pull/621
// Assumes a decentralized custody of assets by the contract in ETH
// Assumes a central authority to update the wei/cent market rate
pragma solidity 0.4.15;

contract PeggedToken
{
	// Copy of the ERC 20 interface

	// Optional
	// function name() constant returns (string name);
	// function symbol() constant returns (string symbol);
	// function decimals() constant returns (uint8 decimals);
	function totalSupply() public constant returns (uint256 _totalSupply);
	function balanceOf(address _owner) public constant returns (uint256 _balance);
	function transfer(address _to, uint256 _value) public returns (bool _success);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success);
	function approve(address _spender, uint256 _value) public returns (bool _success);
	function allowance(address _owner, address _spender) public constant returns (uint256 _remaining);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	// Extended functionality
	function mintPrice() public constant returns (uint256 _mintPrice);
	function burnPrice() public constant returns (uint256 _burnPrice);
	function mint() payable public returns (bool _success);
	function burn(uint256 _value) public returns (bool _success);
	// Central authority operations
	function updatePrice(uint256 _currentPrice) public returns (bool _success);
	function transferAuthority(address _authority) public returns (bool _success);
	event Mint(address indexed _to, uint256 _value);
	event Burn(address indexed _from, uint256 _value);
}

