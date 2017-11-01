pragma solidity ^0.4.2;

import "./Cortex.sol";
import "./Association.sol";
import "./TrustManager.sol";

contract ICO is TrustManager {
	
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
	mapping (address => uint) contributions;

	event Purchase(address indexed _buyer, uint _ethereumSpent);
	event SaleOpen(uint _cortexAvailable);
	event SaleClosed(uint _cortexUnsold);
	event Withdraw(address indexed _target, uint _ethereumAmount);
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

	function buy(uint ceiling) payable duringSale return (bool) {
		require(ethereumRaised <= ceiling);
		uint amt = msg.value;
		require(amt > 0);
		ethereumRaised += amt;
		contributions[msg.sender] = amt;
		Purchase(msg.sender, amt);
		return (contributions[msg.sender] == amt);
	}
	
	function withdrawEther(uint valueInEther) public onlyTrusted returns (bool) {
		amount = valueInEther * 1 ether;
		require(amount <= ethereumReleased);
		ethereumReleased -= amount;
		Withdraw(msg.sender, amount);
		return msg.sender.transfer(amount);
	}

	function withdrawRefund(uint cortexToRefund) public whenRefundable returns (bool) {
	}


}
