// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Errors} from "./libraries/Errors.sol";
import {Events} from "./libraries/Events.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {SismoCredential} from "./SismoCredential.sol";

contract SismoCredentialFactory {
    constructor() {}

    function createCredential(
        bytes16 appId,
        uint256 duration,
        bool isImpersonationMode,
        DataTypes.GroupSetup[] memory groups
    ) external returns (address) {
        SismoCredential sismoCredential = new SismoCredential(msg.sender, appId, duration, isImpersonationMode, groups);
        emit Events.CredentialDeployed(msg.sender, address(sismoCredential));
        return address(sismoCredential);
    }
}
