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
import "./ICO.sol";
import "./Cortex.sol";


contract EasyTestICO is ICO {
    uint public fakeTime = now;

    
    function getTime() internal returns (uint) {
        return fakeTime;
    }

    function setTime(uint time) public {
        fakeTime = time;
    }


}


contract ICOTest is DSTest {

    EasyTestICO ico;

    function setUp() public {
        ico = new EasyTestICO();
        ico.setTime(now);
    }


    function testFailOwnership() public {
        assert(ico.controllingBoard().isTrusted(this));
    }

    function testFailBuyBeforeSale() public {
        assert(ico.buy.value(1)(100));
    }

    function testIsSaleStarted() public {
        ico.setTime(now + 8 days);
        assert(ico.checkIsSale());
    }

    function testBuyWhenSale() public {
        testIsSaleStarted();
        assert(ico.buy.value(1 ether)(100 ether));
    }

    function testFailWithdrawDuringSale() public {
        testBuyWhenSale();
        assert(ico.withdrawRefund(1 ether));
    }

    function testFailReleaseEth() public {
        testBuyWhenSale();
        assert(ico.release(1));
    }

    function testReachGoal() public {
        testIsSaleStarted();
        expectEventsExact(ico);
        assert(ico.buy.value(30000 ether)(50000 ether));
        assert(ico.goalReached());
    }

    function testWithdrawCortex() public {
        testReachGoal();
        ico.setTime(ico.deadline() + 1 days);
        assert(ico.withdrawCortex(1));
    }

    function testCoinInteract() public {
        testWithdrawCortex();
        Cortex c = ico.cortexToken();
        assert(c.balanceOf(this) == 10 ether);
    }
}
