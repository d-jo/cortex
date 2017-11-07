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


contract ERC20Interface {
    // get the total supply of the token
    function totalSupply() public constant returns (uint256 supply);
    // get the account balance of _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);
    // transfer _value tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);
    // transfer _value tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);
    // allow _spender to spend _value tokens from msg.senders account
    function approve(address _spender, uint256 _value) public returns (bool success);
    // returns the amount of tokens _spender has left
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    // event triggered when tokens are transfered
    event Transfer(address indexed _from, address indexed _to, uint _value);
    // event triggered when approve is called
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract Cortex is ERC20Interface {
    // ================================================
    // CONSTANTS
    // ================================================
    string public constant STANDARD = "ERC20";
    string public constant NAME = "cortex";
    string public constant SYMBOL = "ctx";
    uint8 public constant DECIMALS = 10;
    uint256 constant public _totalSupply = (2**64) * (1000000000); // create 2^64 cortex = (2^64) * 1 billion neurons


    // ================================================
    // ERC20 Variables
    // ================================================
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    // constructor for token, assign all tokens to creator
    function Cortex() public {
        balances[msg.sender] = _totalSupply;
    }

    // implementation of ERC20 totalSupply function
    function totalSupply() public constant returns (uint256 supply) {
        supply = _totalSupply;
    }

    // implementation of ERC20 balance function
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner]; // return the balance of the address requested
    }

    // implementation of ERC20 transfer function
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if ((balances[msg.sender] > _value) && (balances[_to] + _value > balances[_to])) {
            // conditions are good, transfer the tokens
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            // alert everyone the transfer took place
            Transfer(msg.sender, _to, _value);
            return true;
        }

        return false;
    }

    // implementation of ERC20 transferFrom function
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        /** conditions, in order:
              1. spender has enough tokens
            2. check for overflow attacks
            3. check that the message sender has the allowance
        */
        if (
            (balances[_from] > _amount) && (balances[_to] + _amount > balances[_to]) && (_amount <= allowed[_from][msg.sender])
        ) {
            // conditions are good, transfer the token
            balances[_from] -= _amount;
            balances[_to] += _amount;
            // subtract the amount sent from senders allowance
            allowed[_from][msg.sender] -= _amount;
            // alert everyone the transfer took place
            Transfer(_from, _to, _amount);
            return true;
        }
        return false;
    }

    // implementation of ERC20 approve function
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    // implementation of ERC20 allowance function
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function () public {
        revert();     // Prevents accidental sending of ether
    }
}
