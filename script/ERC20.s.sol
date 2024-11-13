// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/Test.sol";
import { ERC20 } from "../src/ERC20.sol";

 contract ERC20script is Script {
    function setUp() public {}

    function run() public {
        uint256 private_key = vm.envUint("PRIVATE_KEY");
        /*vm.broadcast() : whatever we're sending in the next statement is actually 
        supposed to be broadcasted to the real network*/
        vm.startBroadcast(private_key);

        new ERC20("Name", "SYM", 18);
        
        vm.stopBroadcast();
    }
}


/* Notes:
    private key is in hexadecimal, to store a hexadeciaml no. in solidity just put 0x in front of it
*/ 