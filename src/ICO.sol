pragma solidity ^0.4.2;

contract ICO {
	
	address public beneficiary;
	uint public ethereumRaised;
	uint public ethereumMax;
	uint public deadline;
	uint public currentPrice;
	token public cortexToken;
	boss public controllingBoard;
	bool public goalReached;
	bool public allowRefunds;
	uint public ethereumReleased;

	event Purchase(address indexed _buyer, uint _ethereumSpent, uint _cortexReceived);
	event SaleOpen(uint _cortexAvailable);
	event SaleClosed(uint _cortexUnsold);
	event Withdrawal(address indexed _target, uint _ethereumAmount);
	event Refund(address indexed _target, uint _cortexAmount);

}
