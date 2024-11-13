// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/Test.sol";
import { ERC20 } from "../src/ERC20.sol";
import { StableCoin } from "../src/StableCoin.sol";
import { DepositorCoin } from "../src/DepositorCoin.sol";
import { Oracle } from "../src/Oracle.sol";
import { FixedPoint } from "../src/FixedPoint.sol";


contract StableCoinScript is Script {
function setUp() public {}

function run() public {
    uint256 private_key = vm.envUint("PRIVATE_KEY");
    /*vm.broadcast() : whatever we're sending in the next statement is actually 
    supposed to be broadcasted to the real network*/
    vm.startBroadcast(private_key);

    Oracle oracle = new Oracle();
    new StableCoin("StableCoin", "STC", oracle, 0, 2, 400);
    
    vm.stopBroadcast();
}
}


/* Notes:
    private key is in hexadecimal, to store a hexadeciaml no. in solidity just put 0x in front of it
*/ 