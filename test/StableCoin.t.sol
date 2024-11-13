// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console} from "forge-std/console.sol";
import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";

import {Oracle} from "../src/Oracle.sol";
import {StableCoin} from "../src/StableCoin.sol";

contract BaseSetup is StableCoin, Test {
    constructor() StableCoin("Stablecoin", "STC", oracle = new Oracle(), 0, 10, 0){}

    function setUp() public virtual {
        oracle.setPrice(4000);
        vm.deal(address(this), 0);//I think it overwrites the native token balance to the specified amount
    }

    //receive function is req cos when Im testing burn, the redeemed ETH is getting sent back to address(this) so we need to handle it
    receive() external payable {
        console.log("Received ETH: %s", msg.value);
    }
}

contract StablecoinDeployedTests is BaseSetup {
    function testSetsFeeRatePercentage() public view {
        assertEq(feeRatePercentage, 0);
    }

    function testAllowsMinting() public {
        uint256 ethAmount = 1e18;
        //console.log("Before deal ", address(this).balance);
        vm.deal(address(this), address(this).balance + ethAmount);
        //console.log("After deal", address(this).balance);
        this.mintStableCoin{value: ethAmount}();
        //console.log("After calling mintStablecoin ", address(this).balance, "%n STC: ", this.totalSupply());


        assertEq(totalSupply, ethAmount * oracle.getPrice());
    }
}

contract WhenStablecoinMintedTokens is BaseSetup {
    uint256 internal mintAmount;

    function setUp() public virtual override {
        BaseSetup.setUp();
        console.log("When user has minted tokens");

        uint256 ethAmount = 1e18;
        mintAmount = ethAmount * oracle.getPrice();

        vm.deal(address(this), address(this).balance + ethAmount);
        this.mintStableCoin{value: ethAmount}();
    }
}

contract MintedTokenTests is WhenStablecoinMintedTokens {
   /* function testFeesWorkingProperly() public view {
        assertEq(mintAmount - this.totalSupply(), 1e18 * oracle.getPrice() * 5 / 100 );
    } */

    function testShouldAllowBurning() public {
        uint256 remainingStablecoinAmount = 100;

        this.redeemETH(mintAmount - remainingStablecoinAmount);//receive() function to receive the eth (line 19)
        assertEq(totalSupply, remainingStablecoinAmount);
    }

    function testCannotDepositBelowInitialCollateralBuffer() public {
        uint256 stableCoinCollateralBuffer = 0.05e18;

        vm.deal(
            address(this),
            address(this).balance + stableCoinCollateralBuffer
        );

        uint256 expectedMinimumDepositAmount = 0.1e18;

        vm.expectRevert(
            abi.encodeWithSelector(
                InitialCollateralRatioError.selector,
                "DPC: First Depositor Min Deposit Amount Not Met Which Is: ",
                expectedMinimumDepositAmount
            )
        );
        this.depositCollateralBuffer{value: stableCoinCollateralBuffer}();
    }

    function testShouldAllowDepositingInitialCollateralBuffer() public {
        uint256 stableCoinCollateralBuffer = 0.5e18;
        vm.deal(
            address(this),
            address(this).balance + stableCoinCollateralBuffer
        );

        this.depositCollateralBuffer{value: stableCoinCollateralBuffer}();

        uint256 newInitialSurplusInUsd = stableCoinCollateralBuffer *
            oracle.getPrice();
        assertEq(this.depositorCoin().totalSupply(), newInitialSurplusInUsd);
    }
}

contract WhenDepositedCollateralBuffer is WhenStablecoinMintedTokens {
    uint256 internal stableCoinCollateralBuffer;

    function setUp() public override {
        WhenStablecoinMintedTokens.setUp();
        console.log("When deposited collateral buffer");

        stableCoinCollateralBuffer = 0.5e18;
        vm.deal(
            address(this),
            address(this).balance + stableCoinCollateralBuffer
        );
        this.depositCollateralBuffer{value: stableCoinCollateralBuffer}();
    }
}

contract DepositedCollateralBufferTests is WhenDepositedCollateralBuffer {
    function testShouldAllowWithdrawingCollateralBuffer() public {
        uint256 newDepositorTotalSupply = stableCoinCollateralBuffer *
            oracle.getPrice();
        uint256 stableCoinCollateralBurnAmount = newDepositorTotalSupply / 5;

        this.withdrawCollateralBuffer(stableCoinCollateralBurnAmount);

        uint256 newDepositorSupply = newDepositorTotalSupply -
            stableCoinCollateralBurnAmount;
        assertEq(this.depositorCoin().totalSupply(), newDepositorSupply);
    }
}
