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
import "./Association.sol";
import "./Cortex.sol";
import "./ICO.t.sol";


contract Holder {
    
    EasyTestICO ico;

    function Holder(EasyTestICO icoToBuy) {
        ico = icoToBuy;
    }

    function buy() returns (bool){
        return ico.buy.value(11000 ether)(100000 ether);
    }

    function withdraw() returns (bool) {
        return ico.withdrawCortex();
    }

    function () payable {

    }
}


contract AssociationTest is DSTest {

    EasyTestICO ico;
    Association board;
    Cortex token;
    Holder mac;
    Holder dennis;
    Holder charlie;

    function setUp() public {
        ico = new EasyTestICO();
        board = ico.controllingBoard();
        token = ico.cortexToken();
        mac = new Holder(ico);
        dennis = new Holder(ico);
        charlie = new Holder(ico);
        mac.send(15000 ether);
        dennis.send(15000 ether);
        charlie.send(15000 ether);
    }

    function testSuccessfulSale() public {
        ico.setTime(now + 8 days);
        assert(mac.buy());
        assert(dennis.buy());
        assert(charlie.buy());
        ico.setTime(ico.fakeTime() + 8 days);
        assert(mac.withdraw());
        assert(dennis.withdraw());
        assert(charlie.withdraw());
    }

    function testNewProposal() public {
        
    }

    

    
}
