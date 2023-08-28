// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Reputation} from "src/Reputation.sol";
import "./Utils.sol";

contract DeployReputation is Utils, Script {
    // the appId from the Sismo Connect App we want to use
    // bytes16 public constant APP_ID = 0xf4977993e52606cfd67b7a1cde717069;
    // bool isImpersonationMode = true; // <--- set to true to allow verifying proofs from impersonated accounts

    bytes16 public constant APP_ID = 0x1267ea070ec44221e85667a731eee045;
    bytes16 public constant DATA_GROUP_ID = 0x7cccd0183c6ca02e76600996a671a824;
    uint256 public constant DURATION = 7 days;

    bool isImpersonationMode = false;

    function run() public {
        vm.startBroadcast();
        Reputation reputation = new Reputation(
            APP_ID,
            DATA_GROUP_ID,
            DURATION,
            isImpersonationMode
        );
        console.log("Airdrop Contract deployed at", address(reputation));
        vm.stopBroadcast();
        string memory path = "./data-group-id.txt";
        string memory data = bytes16ToHexString(DATA_GROUP_ID);
        data = concatStrings("0x", data);
        vm.writeFile(path, data);
    }
}
