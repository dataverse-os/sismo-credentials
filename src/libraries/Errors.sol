// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Errors {
    error InvalidAddress();

    error RefreshDurationNotOver(uint256 remaingingTime);
}
