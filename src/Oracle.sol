// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

contract Oracle {
    uint256 private ethUsdPrice;
    address public owner;

    constructor() {
        owner = msg.sender; 
    }

    function setPrice(uint256 value) external {
        require(msg.sender == owner, "EthUSdPrice: Unauthorised to set price");
        ethUsdPrice = value;
    }

    function getPrice() external view returns(uint256){
        return ethUsdPrice;
    }
}