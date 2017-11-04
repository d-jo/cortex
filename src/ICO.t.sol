pragma solidity ^0.4.2;

import "ds-test/test.sol";
import "./ICO.sol";


contract EasyTestICO is ICO {
    uint public fakeTime = now;

    
    function getTime() internal returns (uint) {
        return fakeTime;
    }

    function setTime(uint time) public {
        fakeTime = time;
    }

    function checkIsSale() public returns (bool) {
        return (getTime() > saleStartTime) && (getTime() < deadline);
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


}
