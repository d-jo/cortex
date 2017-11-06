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

import "./TrustManager.sol";
import "./ICO.sol";
import "./Cortex.sol";


contract Association is TrustManager {
    
    
    uint public minimumQuorum;
    uint public minimumSharesToParticipate;
    uint public voteLengthInMinutes;
    Cortex public cortexToken;
    ICO public controlledContract;
    Proposal[] public proposals;

    struct Vote {
        bool inSupport;
        address voter;
    }

    struct Proposal {
        address recipient;
        uint amount;
        string description;
        uint voteDeadline;
        bool executed;
        bool passed;
        uint voteCount;
        bytes32 hash;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    event RulesetUpdate(address indexed updater, uint minimumQuorum, uint voteLengthInMinutes, uint minimumSharesToParticipate);
    event ProposalCreated(address indexed creator, uint proposalID, address indexed recipient, uint amount, string description);
    event VoteCast(address indexed voter, uint proposalID, bool support);
    event ProposalTallied(uint proposalID, uint result, uint quorum, bool active);
    
    modifier onlyVoters {
        require(cortexToken.balanceOf(msg.sender) > minimumSharesToParticipate);
        _;
    }

    function updateRules(uint newMinimumQuorum, uint newVoteLengthInMinutes, uint newMinimumSharesToParticipate) private {
        if (newMinimumQuorum == 0) {
            newMinimumQuorum = 1;
        }
        minimumQuorum = newMinimumQuorum;
        voteLengthInMinutes = newVoteLengthInMinutes;
        minimumSharesToParticipate = newMinimumSharesToParticipate;
        RulesetUpdate(
            msg.sender, 
            minimumQuorum, 
            voteLengthInMinutes, 
            minimumSharesToParticipate
        );
    }

    function newProposal(
        address recipient, 
        uint weiAmount, 
        string description, 
        bytes transactionBytecode
    ) public onlyVoters returns (uint proposalID) 
    {
        proposalID = proposals.length++;
        Proposal storage p = proposals[proposalID];
        p.recipient = recipient;
        p.amount = weiAmount;
        p.description = description;
        p.hash = keccak256(recipient, weiAmount, transactionBytecode);
        p.voteDeadline = now + voteLengthInMinutes * 1 minutes;
        p.executed = false;
        p.passed = false;
        p.voteCount = 0;
        ProposalCreated(
            msg.sender, 
            proposalID, 
            recipient, 
            weiAmount, 
            description
        );
        return proposalID;
    }

    function newProposalInEther(
        address recipient, 
        uint etherAmount, 
        string description, 
        bytes transactionBytecode
    ) public onlyVoters returns (uint proposalID) 
    {
        return newProposal(
            recipient, 
            etherAmount * 1 ether, 
            description, 
            transactionBytecode
        );
    }
    
    function checkProposalIntegrity(
        uint proposalNumber, 
        address beneficiary, 
        uint weiAmount, 
        bytes transactionBytecode
    ) public constant returns (bool checksOut) 
    {
        Proposal storage p = proposals[proposalNumber];
        return p.hash == keccak256(beneficiary, weiAmount, transactionBytecode);
    }
    
    function vote(uint proposalNumber, bool support) public onlyVoters returns (uint voteID) {
        Proposal storage p = proposals[proposalNumber];
        require(p.voted[msg.sender] != true);
        
        voteID = p.votes.length++;
        p.votes[voteID] = Vote({inSupport: support, voter: msg.sender});
        p.voted[msg.sender] = true;
        p.voteCount = voteID + 1;
        VoteCast(msg.sender, proposalNumber, support);
        return voteID;
    }

    function executeProposal(uint proposalNumber, bytes transactionBytecode) public {
        Proposal storage p = proposals[proposalNumber];

        require(now > p.voteDeadline);
        require(!p.executed);
        require(p.hash == keccak256(p.recipient, p.amount, transactionBytecode));


        uint quorum = 0;
        uint yea = 0;
        uint nay = 0;

        for (uint i = 0; i < p.votes.length; ++i) {
            Vote storage v = p.votes[i];
            uint voteWeight = cortexToken.balanceOf(v.voter);
            quorum += voteWeight;
            if (v.inSupport) {
                yea += voteWeight;
            } else {
                nay += voteWeight;
            }
        }
        
        require(quorum >= minimumQuorum);

        if (yea > nay) {
            p.executed = true;
            require(p.recipient.call.value(p.amount)(transactionBytecode));
            p.passed = true;
        } else {
            p.passed = false;
        }

        ProposalTallied(
            proposalNumber, 
            yea - nay, 
            quorum, 
            p.passed
        );

    }

}
