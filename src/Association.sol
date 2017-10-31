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

	function updateRules(uint newMinimumQuorum, uint newVoteLengthInMinutes, uint newMinimumSharesToParticipate) onlyTrusted {
		if (newMinimumQuorum == 0) newMinimumQuorum = 1;
		minimumQuorum = newMinimumQuorum;
		voteLengthInMinutes = newVoteLengthInMinutes;
		minimumSharesToParticipate = newMinimumSharesToParticipate;
		RulesetUpdate(msg.sender, minimumQuorum, voteLengthInMinutes, minimumSharesToParticipate);
	}

	function newProposal(address recipient, uint weiAmount, string description, bytes transactionBytecode) onlyVoters returns (uint proposalID) {
		proposalID = proposals.length++;
		Proposal storage p = proposals[proposalID];
		p.recipient = recipient;
		p.amount = weiAmount;
		p.description = description;
		p.hash = sha3(recipient, weiAmount, transactionBytecode);
		p.voteDeadline = now + voteLengthInMinutes * 1 minutes;
		p.executed = false;
		p.passed = false;
		p.voteCount = 0;
		ProposalCreated(msg.sender, proposalID, recipient, weiAmount, jobDescription);
		numProposals = proposalID + 1;
		return proposalID;
	}

	function newProposalInEther(address recipient, uint etherAmount, string description, bytes transactionBytecode) onlyVoters returns (uint proposalID) {
		return newProposal(recipient, etherAmount * 1 ether, jobDescription, transactionBytecode);
	}
	
	function checkProposalIntegrity(uint proposalNumber, address beneficiary, uint weiAmount, bytes transactionBytecode) constant returns (bool checksOut) {
		Proposal storage p = proposals[proposalNumber];
		return p.hash == sha3(beneficiary, weiAmount, transactionBytecode);
	}


}
