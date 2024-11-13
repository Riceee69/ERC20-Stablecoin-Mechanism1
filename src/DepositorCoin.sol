// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import {ERC20} from "./ERC20.sol";

//could have used a modifier to implement the mint/burn function locks.

contract DepositorCoin is ERC20 {

    address public owner;
    uint256 public unlockTime;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _unlockTime,
        address to,
        uint256 value
    ) ERC20(_name, _symbol, 18) {
        owner = msg.sender;
        unlockTime = _unlockTime + block.timestamp;

        _mint(to, value);
    }

     
     function mint(address to, uint256 value) external {
        require(msg.sender == owner, "DPC: Unauthorized Caller");
        require(block.timestamp >= unlockTime, "DPC: Minting is locked");

        _mint(to, value);
    }

    function burn(address from, uint256 value) external {
        require(msg.sender == owner, "DPC: Unauthorized Caller");
        require(block.timestamp >= unlockTime, "DPC: Burning is locked");
        require(balanceOf[from] >= value, "DPC: Burn Reverted! Insufficent sender balance");

        _burn(from, value);
    }    
}
