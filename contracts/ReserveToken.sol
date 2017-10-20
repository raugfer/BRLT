// Interface for an extension of the the ERC 20 Token standard
// that allows for minting and burning coins
// Inspired by https://github.com/ethereum/EIPs/pull/621
pragma solidity 0.4.15;

contract ReserveToken
{
	// Copy of the ERC 20 interface

	// Optional
	// function name() constant returns (string name);
	// function symbol() constant returns (string symbol);
	// function decimals() constant returns (uint8 decimals);
	function totalSupply() public constant returns (uint256 _totalSupply);
	function balanceOf(address _owner) public constant returns (uint256 balance);
	function transfer(address _to, uint256 _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
	function approve(address _spender, uint256 _value) public returns (bool success);
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	// Extended functionality

	// Custodian operations
	function custodianLimit(address _custodian) public constant returns (uint256 _custodianLimit);
	function custodianReserve(address _custodian) public constant returns (uint256 _custodianReserve);
	function mint(address _to, uint256 _value, string _meta) public returns (bool success);
	function burn(address _from, uint256 _value, string _meta) public returns (bool success);
	function transferCustody(address _custodian) public returns (bool success);
	function targetOf(address _custodian) public constant returns (address _targetOf);
	// Central authority operations
	function grantCustody(address _custodian, uint256 _limit) public returns (bool success);
	function transferAuthority(address _authority) public returns (bool success);
	event Mint(address _custodian, address indexed _to, uint256 _value, string _meta);
	event Burn(address _custodian, address indexed _from, uint256 _value, string _meta);
}

