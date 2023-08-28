// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Events {
    event ReputationMapped(
        uint256 indexed vaultId, address indexed account, bytes16 indexed groupId, uint256 expiredAt
    );
}
