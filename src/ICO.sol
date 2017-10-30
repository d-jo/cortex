pragma solidity ^0.4.2;

import "./Cortex.sol";
import "./Association.sol";

contract ICO {
	
	struct Vote {
		address voter;
		uint vote;
	}

	address public beneficiary;
	uint public ethereumRaised;
	uint public ethereumMax;
	uint public saleStartTime;
	uint public deadline;
	uint public currentPrice;
	Cortex public cortexToken;
	Association public controllingBoard;
	bool public goalReached;
	bool public allowRefunds;
	uint public ethereumReleased;
	Vote[] public votes;

	event Purchase(address indexed _buyer, uint _ethereumSpent, uint _cortexReceived);
	event SaleOpen(uint _cortexAvailable);
	event SaleClosed(uint _cortexUnsold);
	event Withdrawal(address indexed _target, uint _ethereumAmount);
	event Refund(address indexed _target, uint _cortexAmount);

	modifier coinholders {
		require(token.balanceOf(msg.sender) > 0);
		_;
	}

	modifier whenRefundable {
		require(allowRefund);
		_;
	}

	function ICO() public {
		ethereumRaised = 0 ether;
		ethereumMax = 3000 ether;
		saleStartTime = now + 7 days;
		deadline = saleStartTime + 7 days;
		currentPrice = 12;
		cortexToken = new Cortex();
		controllingBoard = new Association();
		goalReached = false;
		allowRefunds = false;
		ethereumReleased = 0 ether;
	}
}
