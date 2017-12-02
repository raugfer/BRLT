// Interface for a simple ERC 20 Token exchange
pragma solidity ^0.4.15;

contract Exchange
{
	function buyQuote(uint256 _value) public constant returns (uint256 _amount);
	function sellQuote(uint256 _value) public constant returns (uint256 _amount);
	function buy() payable public returns (bool _success);
	function sell(uint256 _value) public returns (bool _success);
	function placeBuyOrder(uint256 _value) payable public returns (uint32 _id);
	function placeSellOrder(uint256 _value, uint256 _amount) public returns (uint32 _id);
	function order(uint32 _id) public returns (uint256 _value, uint256 _amount);
	function cancelBuyOrder(uint32 _id) public returns (bool _success);
	function cancelSellOrder(uint32 _id) public returns (bool _success);

	event Buy(address indexed _buyer, address indexed _seller, uint256 _value, uint256 _amount, uint32 _id, bool _complete);
	event Sell(address indexed _buyer, address indexed _seller, uint256 _value, uint256 _amount, uint32 _id, bool _complete);
	event PlaceBuyOrder(address indexed _owner, uint256 _value, uint256 _amount, uint32 _id);
	event PlaceSellOrder(address indexed _owner, uint256 _value, uint256 _amount, uint32 _id);
	event CancelBuyOrder(address indexed _owner, uint256 _value, uint256 _amount, uint32 _id);
	event CancelSellOrder(address indexed _owner, uint256 _value, uint256 _amount, uint32 _id);
}

