/*
   Copyright 2017 Declan Johnson

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
pragma solidity ^0.4.2;

import "./Cortex.sol";
import "./Association.sol";


contract ICO {
    
    address public beneficiary;
    uint public ethereumRaised;
    uint public saleStartTime;
    uint public deadline;
    uint public constant CORTEX_PER_ETH = 10;
    Cortex public cortexToken;
    Association public controllingBoard;
    bool public goalReached;
    uint public ethereumReleased;
    uint public constant GOAL_IN_ETHER = 25000 ether;
    mapping (address => uint) contributions;

    event Purchase(address indexed _buyer, uint _ethereumSpent);
    event SaleOpen(uint _cortexAvailable);
    event SaleClosed(uint _cortexUnsold);
    event GoalReached();
    event Withdraw(address indexed _target, uint _ethereumAmount);
    event Refund(address indexed _target, uint _ethereumAmount);

    modifier duringSale {
        require(getTime() > saleStartTime);
        require(getTime() < deadline);
        _;
    }

    modifier afterSuccessfulSale {
        require(getTime() > deadline);
        require(goalReached);
        _;
    }
    
    modifier afterFailedSale {
        require(getTime() > deadline);
        require(!goalReached);
        _;
    }

    function ICO() public {
        beneficiary = msg.sender;
        ethereumRaised = 0 ether;
        saleStartTime = getTime() + 7 days;
        deadline = saleStartTime + 7 days;
        cortexToken = new Cortex();
        controllingBoard = new Association();
        goalReached = false;
        ethereumReleased = 0 ether;
    }

    function getTime() internal returns (uint) {
        return now;
    }

    function buy(uint ceiling) public payable duringSale returns (bool) {
        require(ethereumRaised <= ceiling);
        uint amt = msg.value;
        require(amt > 0);
        ethereumRaised += amt;
        contributions[msg.sender] = amt;
        Purchase(msg.sender, amt);
        if (ethereumRaised >= GOAL_IN_ETHER) {
            goalReached = true;
            GoalReached();
        }
        return (contributions[msg.sender] == amt);
    }

    function withdrawCortex() public afterSuccessfulSale returns (bool) {
        uint contrib = contributions[msg.sender];
        uint cortexReward = contrib * CORTEX_PER_ETH;
        if (cortexToken.transfer(msg.sender, cortexReward)) {
            contributions[msg.sender] = 0;
            return true;
        } else {
            return false;
        }
    }
    
    function withdrawEther() public returns (bool) {
        require(msg.sender == beneficiary);
        uint amount = ethereumReleased;
        ethereumReleased = 0;
        return msg.sender.send(amount);
    }

    function withdrawRefund() public afterFailedSale returns (bool) {
        uint balance = contributions[msg.sender];
        contributions[msg.sender] = 0;
        Refund(msg.sender, balance);
        return msg.sender.send(balance);
    }

    function release(uint ethAmount) public returns (bool) {
        require(controllingBoard.isTrusted(msg.sender));
        ethereumReleased += ethAmount;
        return true;
    }

    function checkIsSale() public returns (bool) {
        return (getTime() > saleStartTime) && (getTime() < deadline);
    }


}
