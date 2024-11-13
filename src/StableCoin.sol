// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import {ERC20} from "./ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "./Oracle.sol";
import {FixedPoint, fromFraction, mulFixedPoint, divFixedPoint} from "./FixedPoint.sol";//handle decimals.

contract StableCoin is ERC20 {
    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 public feeRatePercentage;
    uint256 public initialCollateralRatioPercentage;
    uint256 public firstDepositorLockPeriod;

    error InitialCollateralRatioError(string message, uint256 minimumDepositAmount);

    constructor(
        string memory _name,
        string memory _symbol,
        Oracle _oracle,
        uint256 _feeRatePercentage,
        uint256 _initialCollateralRatioPercentage,
        uint256 _firstDepositorLockPeriod
    ) ERC20(_name, _symbol, 18) {
        oracle = _oracle;
        feeRatePercentage = _feeRatePercentage;
        initialCollateralRatioPercentage = _initialCollateralRatioPercentage;
        firstDepositorLockPeriod = _firstDepositorLockPeriod;
    }

    //To stop minting/reedeming the STC when Liquidty underwater.
    modifier notUnderwater {
        int256 surplusOrDeficitInUsd = _getSurplusOrDeficitInUsd();
        require( surplusOrDeficitInUsd >= 0, "Minting/Redeeming closed at the moment");
        _;
    }

    function mintStableCoin() external payable notUnderwater {
        uint256 ethUsdPrice = oracle.getPrice();
        uint256 feesInEth = _getFeesInEth(msg.value);

        uint256 stableCoinAmount = (msg.value - feesInEth) * ethUsdPrice;
        _mint(msg.sender, stableCoinAmount);
    }

    function redeemETH(uint256 stableCoinAmount) external notUnderwater {
        _burn(msg.sender, stableCoinAmount);

        uint256 ethUsdPrice = oracle.getPrice();

        uint256 refundEth = stableCoinAmount / ethUsdPrice;
        uint256 feesInEth = _getFeesInEth(refundEth);

        (bool success, ) = msg.sender.call{value: refundEth - feesInEth}("");

        require(success, "STC: ETH Redeem Failed.");
    }

    function depositCollateralBuffer() external payable {
        uint256 ethUsdPrice = oracle.getPrice();
        uint256 depositUsdValue = msg.value * ethUsdPrice;
        int256 surplusOrDeficitInUsd = _getSurplusOrDeficitInUsd();

        if (surplusOrDeficitInUsd <= 0) {

            uint256 deficitInUsd = uint256(surplusOrDeficitInUsd * -1);
            uint256 initialDepositAmount = depositUsdValue - deficitInUsd;//since DpcPriceInUsd = 1 at the beginning. 

            uint256 initialCollateralRatio = initialCollateralRatioPercentage *  totalSupply / 100;

            if(initialDepositAmount < initialCollateralRatio){
                uint256 minDepositAmountInEth = (deficitInUsd + initialCollateralRatio) / oracle.getPrice();
                revert InitialCollateralRatioError("DPC: First Depositor Min Deposit Amount Not Met Which Is: ", minDepositAmountInEth);
            }

            depositorCoin = new DepositorCoin("Depositor Coin", "DPC", firstDepositorLockPeriod, msg.sender, initialDepositAmount);

            return;

        }

        uint256 surplusInUsd = uint256(surplusOrDeficitInUsd);
        FixedPoint UsdInDpcPrice = fromFraction(depositorCoin.totalSupply(), surplusInUsd);
        uint256 depositorCoinAmount = mulFixedPoint(depositUsdValue, UsdInDpcPrice);
        depositorCoin.mint(msg.sender, depositorCoinAmount);

    }

    function withdrawCollateralBuffer(uint256 depositorCoinAmount) external {
        uint256 ethUsdPrice = oracle.getPrice();
        int256 surplusOrDeficitInUsd = _getSurplusOrDeficitInUsd();

        require(surplusOrDeficitInUsd > 0, "DPC: No collateral funds to withrdraw from");

        uint256 surplusInUsd = uint256(surplusOrDeficitInUsd);
        depositorCoin.burn(msg.sender, depositorCoinAmount);

        FixedPoint UsdInDpcPrice = fromFraction(depositorCoin.totalSupply(), surplusInUsd);

        uint256 refundingUsd = divFixedPoint(depositorCoinAmount, UsdInDpcPrice);

        uint256 refundEth = refundingUsd / ethUsdPrice;
        (bool success, ) = msg.sender.call{value: refundEth}("");

        require(success, "DC: ETH Withdraw Failed.");

        

    }

    function _getSurplusOrDeficitInUsd() private view returns (int256) {
        uint256 ethUsdPrice = oracle.getPrice();
        int256 surplusOrDeficitInUSd = int256((address(this).balance - msg.value) * ethUsdPrice) - int256(totalSupply);
        return surplusOrDeficitInUSd;
    }

    function _getFeesInEth(uint256 value) private view returns (uint256) {
        return (feeRatePercentage * value) / 100;
    }
}
