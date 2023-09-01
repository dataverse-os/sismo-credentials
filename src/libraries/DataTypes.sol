// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library DataTypes {
    struct Account {
        address account;
        uint256 refreshAfter;
    }

    struct CredentialInfo {
        bytes16 groupId;
        bool value;
        uint256 expiredAt;
    }

    struct GroupSetup {
        uint256 startAt;
        bytes16 groupId;
        uint256 duration;
    }
}
