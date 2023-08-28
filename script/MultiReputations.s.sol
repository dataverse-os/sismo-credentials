// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {MultiReputations} from "src/MultiReputations.sol";
import "../src/MultiReputations.sol";
import "./Utils.sol";

contract DeployMultiReputations is Script {
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
        MultiReputations.GroupSetup[] memory groups = new MultiReputations.GroupSetup[](2);
        groups[0] = (MultiReputations.GroupSetup({groupId: TEAM_MEMBERS_GROUP_ID, startAt: 1000, duration: 1 days}));
        groups[1] = (MultiReputations.GroupSetup({groupId: G2M_GROUP_ID, startAt: 12000, duration: 1 days}));

        vm.startBroadcast();
        MultiReputations reputation = new MultiReputations(
            APP_ID,
            DURATION,
            isImpersonationMode,
            groups
        );

        vm.stopBroadcast();
        
        console.log("MultiReputation Contract deployed at", address(reputation));

    }
}
