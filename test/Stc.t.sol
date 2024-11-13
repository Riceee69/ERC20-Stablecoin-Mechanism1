// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";
import{Oracle} from "../src/Oracle.sol";

contract BaseSetup is StableCoin, Test {
    constructor() StableCoin("Name", "SYM", new Oracle(), 5, 10, 0 ){}

    function setUp() public virtual {
        oracle.setPrice(1000);
        vm.deal(address(this), 0);
    }

    receive() payable external{
        console.log("Received ETH: ", msg.value);
    }
}

contract TestMintStableCoin is BaseSetup{
    function testIsMintingAmountProperly() public{
        uint256 ethAmount = 1e18;
        uint256 ethAmountInUsd = ethAmount * oracle.getPrice();
        uint256 amountUsdAfterTax = ethAmountInUsd - (ethAmountInUsd * 5 / 100);

        vm.deal(address(this), address(this).balance + ethAmount);
        this.mintStableCoin{value: ethAmount}();

        assertEq(amountUsdAfterTax, this.totalSupply());
        assertEq(ethAmount, address(this).balance);
    }
}

contract StablecoinIsMinted is BaseSetup {
     uint256 internal mintAmount; 

    function setUp() public override{
        BaseSetup.setUp();
        console.log("Minting Tokens to the address");
        uint256 ethAmount = 1e18;

        vm.deal(address(this), address(this).balance + ethAmount);
        this.mintStableCoin{value: ethAmount}();
        mintAmount = this.totalSupply();
        console.log(mintAmount);
    }
}

contract TestsAfterStableCoinMint is StablecoinIsMinted {

    function testIsBurningAmountProperly() public{
        uint256 remainingStableCoinAmount = 10000;

        this.redeemETH(mintAmount - remainingStableCoinAmount);

        assertEq(this.totalSupply(), remainingStableCoinAmount);
    }

    function testInitalCollateralRatio() public {
        uint256 stableCoinCollateralBuffer = 0.05e18;

        vm.deal(
            address(this),
            address(this).balance + stableCoinCollateralBuffer
        );

        uint256 expectedMinimumDepositAmount = mintAmount * 10 / 100;

        vm.expectRevert(
            abi.encodeWithSelector(
                InitialCollateralRatioError.selector,
                "DPC: First Depositor Min Deposit Amount Not Met Which Is: ",
                expectedMinimumDepositAmount
            )
        );
        this.depositCollateralBuffer{value: stableCoinCollateralBuffer}();
    }

}

contract TestDepositCollateralBuffer is BaseSetup {
    uint256 mintAmount; 

    function setUp() public override {
        BaseSetup.setUp();
        uint256 ethAmount = 1e18;
        mintAmount = ethAmount * oracle.getPrice();

        vm.deal(address(this), address(this).balance + ethAmount);
        this.depositCollateralBuffer{value: ethAmount}();
    }

    function testMintDepositorCoin() public view {
       assertEq(mintAmount, depositorCoin.totalSupply());
    }

}