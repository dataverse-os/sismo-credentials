// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {SismoCredential} from "src/SismoCredential.sol";
import {DataTypes} from "src/libraries/DataTypes.sol";
import "../src/CredentialFactory.sol";

contract DeployCredentialFactory is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.broadcast(deployerPrivateKey);
        new CredentialFactory();
    }
}
