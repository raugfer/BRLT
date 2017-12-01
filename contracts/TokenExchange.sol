// Interface for a simple ERC 20 Token exchange
pragma solidity ^0.4.15;

contract TokenExchange
{
	function buyQuote(uint256 _value) public constant returns (uint256 _amount);
	function sellQuote(uint256 _amount) public constant returns (uint256 _value);
	function buy() payable public returns (bool _success);
	function sell(uint256 _amount) public returns (bool _success);
	function placeBuyOrder(uint256 _amount) payable public returns (uint32 _id);
	function placeSellOrder(uint256 _amount, uint256 _value) public returns (uint32 _id);
	function cancelBuyOrder(uint32 _id) public returns (bool _success);
	function cancelSellOrder(uint32 _id) public returns (bool _success);

	event Buy(address _buyer, uint256 _value, uint256 _amount, address _seller, uint32 _id, bool _complete);
	event Sell(address _seller, uint256 _amount, uint256 _value, address _buyer, uint32 _id, bool _complete);
	event PlaceBuyOrder(address _owner, uint256 _value, uint256 _amount, uint32 _id);
	event PlaceSellOrder(address _owner, uint256 _amount, uint256 _value, uint32 _id);
	event CancelBuyOrder(address _owner, uint256 _value, uint256 _amount, uint32 _id);
	event CancelSellOrder(address _owner, uint256 _amount, uint256 _value, uint32 _id);
}

