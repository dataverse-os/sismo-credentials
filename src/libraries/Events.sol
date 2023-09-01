// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Events {
    event CredentialMapped(
        uint256 indexed vaultId, address indexed account, bytes16 indexed groupId, uint256 expiredAt
    );

    event CredentialAdded(bytes16 indexed groupId, uint256 timestamp);

    event CredentialRemoved(bytes16 indexed groupId, uint256 timestamp);
}
