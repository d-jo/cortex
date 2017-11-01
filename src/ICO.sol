pragma solidity ^0.4.2;

import "./Cortex.sol";
import "./Association.sol";
import "./TrustManager.sol";

contract ICO is TrustManager {
	
	uint public ethereumRaised;
	uint public ethereumMax;
	uint public saleStartTime;
	uint public deadline;
	uint public constant cortexPerEther = 10;
	Cortex public cortexToken;
	Association public controllingBoard;
	bool public goalReached;
	uint public ethereumReleased;
	uint public constant goalInEthereum = 25000 ether;
	mapping (address => uint) contributions;

	event Purchase(address indexed _buyer, uint _ethereumSpent);
	event SaleOpen(uint _cortexAvailable);
	event SaleClosed(uint _cortexUnsold);
	event GoalReached();
	event Withdraw(address indexed _target, uint _ethereumAmount);
	event Refund(address indexed _target, uint _ethereumAmount);

	modifier duringSale {
		require(now > saleStartTime);
		require(now < deadline);
		_;
	}

	modifier afterSuccessfulSale {
		require(now > deadline);
		require(goalReached);
		_;
	}
	
	modifier afterFailedSale {
		require(now > deadline);
		require(!goalReached);
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
		if (ethereumRaised >= goalInEthereum) {
			goalReached = true;
			GoalReached();
		}
		return (contributions[msg.sender] == amt);
	}

	function withdrawCortex(uint valueInCortex) public afterSuccesfulSale returns (bool) {
		uint contrib = contributions[msg.sender];
		uint cortexReward = (contributions[msg.sender] * 1 ether) * cortexPerEther;
		return cortexToken.transfer(msg.sender, cortexReward);
	}
	
	function withdrawEther(uint valueInEther) public onlyTrusted returns (bool) {
		amount = valueInEther * 1 ether;
		require(amount <= ethereumReleased);
		ethereumReleased -= amount;
		return msg.sender.transfer(amount);
	}

	function withdrawRefund(uint etherToWithdraw) public afterFailedSale returns (bool) {
		uint amt = etherToWithdraw * 1 ether;
		uint balance = contributions[msg.sender];
		require(amt <= balance); 
		contributions[msg.sender] = balance - amt; 
		Refund(msg.sender, amount);
		return msg.sender.transfer(amt);
	}

	function release(uint ethAmount) public onlyTrusted returns (bool) {
		
	}



}
