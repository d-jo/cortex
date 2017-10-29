pragma solidity ^0.4.2;

contract Association {
	
	uint public minimumQuorum;
	uint[] public scheduledVotes;
	uint[] public pastResults;
	uint public voteLength;
	token public cortexToken;
	ico public controlledContract;

	event VoteCast();
	event VoteStart();
	event VoteEnd();
	event Results();

	

}
