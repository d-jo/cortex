pragma solidity ^0.4.2;

contract owned {

	mapping (address => bool) private trusted;
	event UserTrusted(address indexed truster, address indexed trustee);
	event UserUntrusted(address indexed trusted, address indexed target);

	function owned() public {
		trusted[msg.sender] = true;
	}

	modifier onlyTrusted {
		require(trusted[msg.sender]);
		_;
	}

	function addTrusted(address target) onlyTrusted public {
		trusted[target] = true;
		UserTrusted(msg.sender, target);
	}

	function removeTrusted(address target) onlyTrusted public {
		trusted[target] = false;
		UserUntrusted(msg.sender, target);
		
	}

}
