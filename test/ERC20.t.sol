// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2, StdStyle} from "forge-std/Test.sol";
import {ERC20} from "../src/ERC20.sol";
import "forge-std/StdUtils.sol";

contract BaseSetup is ERC20, Test {
    address internal alice;
    address internal bob;

    constructor() ERC20("Name", "SYM", 18) {}

    //setUp function automatically run by foundry/forge as testing initiates.
    function setUp() public virtual {
        alice = makeAddr("alice"); //Test function to generate an address and name it alice
        bob = makeAddr("bob");

        console2.log(StdStyle.blue("When Alice has 300 Tokens"));
        _mint(alice, 300e18);
        //deal function is used to mint tokens of an ERC20 contract to an address irrespective of whether the contract has mint functionality or not
        //deal(address(this), alice, 300e18); //works the same as _mint function
    }
}

contract ERC20TransferTest is BaseSetup {
    //we can have seperate setup func for other contracts
    function setUp() public override {
        BaseSetup.setUp();
        //write codes here for this setup func
    }

    function testTransfersTokenCorrectly() public {
        vm.prank(alice); //Test function which tells the code that the transfer in next line is done from alice.
        bool success = this.transfer(bob, 100e18);

        //Foundry Assertions
        assertTrue(success); //checking if true is returned

        assertEqDecimal(balanceOf[alice], 200e18, decimals); //checking transfer logic
        assertEqDecimal(balanceOf[bob], 100e18, decimals);
    }

    function testCannotTransferMoreThanBalance() public {
        vm.prank(alice);
        vm.expectRevert("ERC20: Insufficient sender balance");
        this.transfer(bob, 400e18);
    }

    function testEmitTransferEvent() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, 100e18);

        vm.prank(alice);
        this.transfer(bob, 100e18);
    }
}

contract ERC20TransferFromTest is BaseSetup {

    function setUp() public override{
        BaseSetup.setUp();
        allowance[alice][address(this)] = 300e18;
    }

    function testTransfersTokenCorrectly() public{
        bool success = this.transferFrom(alice, bob, 100e18);
        assertTrue(success);

        assertEqDecimal(balanceOf[alice], 200e18, decimals );
        assertEqDecimal(balanceOf[bob], 100e18, decimals );


    }

    function testCannotTransferMoreThanAllowance() public{
        vm.expectRevert("ERC20: Insufficient allowance");
        this.transferFrom(alice, bob, 400e18);
    }

    function testEmitsTransferEvent() public{
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, 100e18);

        this.transferFrom(alice, bob, 100e18);
    }

    function testEmitsApprovalEvent() public{
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, address(this), 200e18);

        this.transferFrom(alice, bob, 100e18);
    }


}

/* Notes:

    assertEq()/assertEqDecimal() :  latter just puts a decimal dot in the desired decimal place 
    eg: in the above code former would show 100(18 0's) latter will show 100.(18 0's)


    vm.expectEmit() it expects four boolean parameters true/false, first three are to indicate whether the three indexed paramters of 
    the Event are checked and the fourth indicates whether all the unidexed attributes are getting checked.
    eg: if second is set to false then it wont check who is the receiver. So, we can even log alice as receiver and the test will pass. 
 */
