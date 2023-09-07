//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {BaseTest} from "./base/BaseTest.t.sol";
import {SismoCredentialFactory} from "../src/SismoCredentialFactory.sol";
import {DataTypes} from "../src/libraries/DataTypes.sol";
import {Events} from "../src/libraries/Events.sol";

contract SismoCredentialFactoryTest is BaseTest {
    SismoCredentialFactory public credentialFactory;

    bool isImpersonationMode = false; // <--- set to true to allow verifying proofs from impersonated accounts
    // sismo dataGroupIds
    bytes16 public constant TEAM_MEMBERS_GROUP_ID = 0xf44c3e70f9147f1a4d59077451535f00;
    bytes16 public constant G2M_GROUP_ID = 0x7cccd0183c6ca02e76600996a671a824;

    // bytes16 public constant DATA_GROUP_ID = 0x6d6ab4793a05fbdafbb8895f8e9eef14; // ten eths group

    // sismo appId
    bytes16 public constant APP_ID = 0x1267ea070ec44221e85667a731eee045;
    uint256 public constant REFRESH_DURATION = 7 days;

    address public owner = 0xb5AB443DfF53F0e397a9E0778A3343Cbaf4D001a;
    address public creator = 0xb5AB443DfF53F0e397a9E0778A3343Cbaf4D001a;

    function setUp() public {
        _registerTreeRoot(0x04f0ace60fdf560415b93173156e67c6735946e9889973bfd56f1bcbe6fc5bcf);
        vm.prank(owner);
        credentialFactory = new SismoCredentialFactory();
    }

    function test_createCredential() public {
        DataTypes.GroupSetup[] memory groups = new DataTypes.GroupSetup[](2);
        groups[0] = (DataTypes.GroupSetup({groupId: TEAM_MEMBERS_GROUP_ID, startAt: 1000, duration: 1 days}));
        groups[1] = (DataTypes.GroupSetup({groupId: G2M_GROUP_ID, startAt: 12000, duration: 1 days}));

        vm.prank(creator);
        vm.expectEmit(true, false, false, true);
        emit Events.CredentialDeployed(creator, address(0));
        credentialFactory.createCredential(APP_ID, REFRESH_DURATION, isImpersonationMode, groups);
    }
}
