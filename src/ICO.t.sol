pragma solidity ^0.4.2;

import "ds-test/test.sol";
import "./ICO.sol";


contract EasyTestICO is ICO {
    uint public fakeTime;

    
    function getTime() internal returns (uint) {
        return fakeTime;
    }



}

contract ICOTest is DSTest {

    ICO ico;

    function setUp() public {
        
    }

}
