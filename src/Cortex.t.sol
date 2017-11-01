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
        assertEq(cortex.totalSupply(), 0xffffffff);
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
