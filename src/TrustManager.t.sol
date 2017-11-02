pragma solidity ^0.4.2;

import "ds-test/test.sol";
import "./TrustManager.sol";


contract Dennis is TrustManager {
    
    function demonstrateValue(uint a, uint b) public onlyTrusted returns (uint) {
        return a + b;
    }

}


contract Mac {

    function askDennis(Dennis dennis) public returns (bool) {
        return dennis.demonstrateValue(1, 1) == 2;
    }

}


contract TrustManagerTest is TrustManager, DSTest {

    Dennis public dennis;
    Mac public mac;

    function setUp() public {
        dennis = new Dennis();
        mac = new Mac();
    }

    function testIsTrusted() public {
        assert(dennis.isTrusted(this) == true);
    }

    function testFailIsTrusted() public {
        assert(isTrusted(dennis));
    }

    function testAddTrusted() public {
        assert(!dennis.isTrusted(mac));
        expectEventsExact(dennis);
        dennis.addTrusted(mac);
        assert(dennis.isTrusted(mac));
    }

    function testRemoveTrusted() public {
        dennis.addTrusted(mac);
        expectEventsExact(dennis);
        assert(dennis.isTrusted(mac));
        dennis.removeTrusted(mac);
        assert(!dennis.isTrusted(mac));
    }
    
}
