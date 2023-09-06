// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {SismoCredential} from "src/SismoCredential.sol";
import {CredentialFactory} from "src/CredentialFactory.sol";
import {DataTypes} from "src/libraries/DataTypes.sol";
import {SismoCredentialFactory} from "../src/SismoCredentialFactory.sol";

contract DeploySismoCredential is Script {
    address credentialFactoryAddr = 0x1Cb68d1149b78F0528414B78F72eD2A0305E39d4;
    // sismo dataGroupIds
    bytes16 public constant TEAM_MEMBERS_GROUP_ID = 0xf44c3e70f9147f1a4d59077451535f00;
    bytes16 public constant G2M_GROUP_ID = 0x7cccd0183c6ca02e76600996a671a824;
    // bytes16 public constant DATA_GROUP_ID = 0x6d6ab4793a05fbdafbb8895f8e9eef14; // ten eths group

    // sismo appId
    bytes16 public constant APP_ID = 0x1267ea070ec44221e85667a731eee045;
    uint256 public constant DURATION = 7 days;
    bool isImpersonationMode = false;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // config dataGroups
        DataTypes.GroupSetup[] memory groups = new DataTypes.GroupSetup[](2);
        groups[0] = (DataTypes.GroupSetup({groupId: TEAM_MEMBERS_GROUP_ID, startAt: 1000, duration: 1 days}));
        groups[1] = (DataTypes.GroupSetup({groupId: G2M_GROUP_ID, startAt: 12000, duration: 1 days}));

        CredentialFactory factory = CredentialFactory(credentialFactoryAddr);
        
        vm.broadcast(deployerPrivateKey);
        address newCredential = factory.createCredential(APP_ID, DURATION, isImpersonationMode, groups);
        console.log("new deployed credential: ", newCredential);
    }
}
