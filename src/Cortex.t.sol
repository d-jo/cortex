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

import "ds-test/test.sol";

import "./Cortex.sol";


contract TokenActor {
    
    Cortex cortex;

    function TokenActor(Cortex cortex_) public {
        cortex = cortex_;
    }

    function doApprove(address spender, uint256 amount) public returns (bool) {
        return cortex.approve(spender, amount);
    }

    function doTransfer(address to, uint256 amount) public returns (bool) {
        return cortex.transfer(to, amount);
    }

    function doTransferFrom(address from, address to, uint256 amount) public returns (bool) {
        return cortex.transferFrom(from, to, amount);
    }

    function doBalance(address owner) public returns (uint) {
        return cortex.balanceOf(owner);
    }

}


contract CortexTest is DSTest {

    Cortex cortex;
    TokenActor mac;
    TokenActor dennis;

    function setUp() public {
        cortex = new Cortex();
        mac = new TokenActor(cortex);
        dennis = new TokenActor(cortex);
        cortex.transfer(dennis, 1337);
    }
    
    function testTotalSupply() public {
        assertEq(cortex.totalSupply(), (2**64) * (1000000000));
    }

    function testBalanceOf() public {
        assertEq(cortex.balanceOf(mac), 0);
        assertEq(cortex.balanceOf(dennis), 1337);
    }

    function testTransfer() public {
        expectEventsExact(cortex);
        uint256 prebalance = mac.doBalance(this);
        assert(cortex.transfer(mac, 100));
        assertEq(mac.doBalance(this), prebalance - 100);
        assertEq(cortex.balanceOf(mac), 100);
        assert(mac.doTransfer(cortex, 50));
        assertEq(cortex.balanceOf(mac), 50);
    }

    function testFailBadTransfer() public {
        assert(mac.doTransfer(dennis, 0));
    }

    function testApprove() public {
        expectEventsExact(cortex);
        assert(dennis.doApprove(mac, 337));
    }

    function testTransferFrom() public {
        dennis.doApprove(mac, 337);
        assert(mac.doTransferFrom(dennis, this, 37));    
    }
    
    function testFailTransferFrom() public {
        assert(mac.doTransferFrom(dennis, this, 37777));    
    }    

    function testAllowance() public {
        dennis.doApprove(mac, 337);
        assertEq(cortex.allowance(dennis, mac), 337);
    }

}
