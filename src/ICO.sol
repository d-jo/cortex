pragma solidity ^0.4.2;

import "./Cortex.sol";
import "./Association.sol";
import "./Beneficiary.sol";

contract ICO is owned {
	
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

	event Purchase(address indexed _buyer, uint _ethereumSpent, uint _cortexReceived);
	event SaleOpen(uint _cortexAvailable);
	event SaleClosed(uint _cortexUnsold);
	event Withdrawal(address indexed _target, uint _ethereumAmount);
	event Refund(address indexed _target, uint _cortexAmount);

	modifier duringSale {
		require(now > saleStartTime);
		require(now < deadline);
		_;
	}
	
	modifier whenRefundable {
		require(allowRefunds);
		_;
	}

	function ICO() public {
		beneficiaryList.push(msg.sender);
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

	function buy(uint ceiling) payable duringSale {
		require(ethereumRaised <= ceiling);
		uint amt = msg.value;
		ethereumRaised += amt;
		//todo give tokens
	}
	
	function withdrawl(uint amount) public onlyTrusted {
		require(amount <= ethereumReleased);
		ethereumReleased -= amount;
		msg.sender.transfer(amount);
	}


}
