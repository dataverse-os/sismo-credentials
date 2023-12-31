// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {SismoCredential} from "src/SismoCredential.sol";
// import {SismoCredentialFactory} from "src/SismoCredentialFactory.sol";
import {DataTypes} from "src/libraries/DataTypes.sol";

contract DeploySismoCredential is Script {
    // sismo dataGroupIds
    bytes16 public constant TEAM_MEMBERS_GROUP_ID = 0xf44c3e70f9147f1a4d59077451535f00;
    bytes16 public constant G2M_GROUP_ID = 0x7cccd0183c6ca02e76600996a671a824;
    // bytes16 public constant DATA_GROUP_ID = 0x6d6ab4793a05fbdafbb8895f8e9eef14; // ten eths group

    // sismo appId
    bytes16 public constant APP_ID = 0x1267ea070ec44221e85667a731eee045;
    uint256 public constant REFRESH_DURATION = 7 days;
    bool isImpersonationMode = false;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // config dataGroups
        DataTypes.GroupSetup[] memory groups = new DataTypes.GroupSetup[](2);
        groups[0] = (DataTypes.GroupSetup({groupId: TEAM_MEMBERS_GROUP_ID, startAt: 1000, duration: 1 days}));
        groups[1] = (DataTypes.GroupSetup({groupId: G2M_GROUP_ID, startAt: 12000, duration: 1 days}));

        vm.broadcast(deployerPrivateKey);
        new SismoCredential(vm.addr(deployerPrivateKey), APP_ID, REFRESH_DURATION, isImpersonationMode, groups);
    }
}
