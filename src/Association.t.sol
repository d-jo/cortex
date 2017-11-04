pragma solidity ^0.4.2;

import "ds-test/test.sol";
import "./ICO.sol";
import "./Association.sol";
import "./ICO.t.sol";


contract AssociationTest is DSTest {

    EasyTestICO ico;
    Association board;

    function setUp() public {
        ico = new EasyTestICO();
        board = ico.controllingBoard();
    }


    
}
