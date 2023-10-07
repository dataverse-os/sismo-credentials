// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {SismoCredentialFactory} from "src/SismoCredentialFactory.sol";
import {DataTypes} from "src/libraries/DataTypes.sol";
import "../src/SismoCredentialFactory.sol";

contract DeploySismoCredentialFactory is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.broadcast(deployerPrivateKey);
        new SismoCredentialFactory();
    }
}
