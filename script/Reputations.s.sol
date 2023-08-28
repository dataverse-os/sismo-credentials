// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Reputations} from "src/Reputations.sol";
import "./Utils.sol";

contract DeployReputations is Script {
    // sismo dataGroupIds
    bytes16 public constant TEAM_MEMBERS_GROUP_ID = 0xf44c3e70f9147f1a4d59077451535f00;
    bytes16 public constant G2M_GROUP_ID = 0x7cccd0183c6ca02e76600996a671a824;
    // bytes16 public constant DATA_GROUP_ID = 0x6d6ab4793a05fbdafbb8895f8e9eef14; // ten eths group

    // sismo appId
    bytes16 public constant APP_ID = 0x1267ea070ec44221e85667a731eee045;
    uint256 public constant DURATION = 7 days;
    bool isImpersonationMode = false;

    function run() public {
        // config the dataGroups
        Reputations.GroupSetup[] memory groups = new Reputations.GroupSetup[](2);
        groups[0] = (Reputations.GroupSetup({groupId: TEAM_MEMBERS_GROUP_ID, startAt: 1000, duration: 1 days}));
        groups[1] = (Reputations.GroupSetup({groupId: G2M_GROUP_ID, startAt: 12000, duration: 1 days}));

        vm.startBroadcast();
        Reputations reputation = new Reputations(
            APP_ID,
            DURATION,
            isImpersonationMode,
            groups
        );

        vm.stopBroadcast();
        
        console.log("MultiReputation Contract deployed at", address(reputation));
    }
}
