pragma solidity ^0.4.19-develop.2017.10.25;

import "ds-test/test.sol";

import "./Cortex.sol";

contract CortexTest is DSTest {
    Cortex cortex;

    function setUp() {
        cortex = new Cortex();
    }

    function testFail_basic_sanity() {
        assert(false);
    }

    function test_basic_sanity() {
        assert(true);
    }
}
