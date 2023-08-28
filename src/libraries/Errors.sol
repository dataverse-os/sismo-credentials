// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Errors {
    error InvalidAddress();

    error UnableToBindBefore(uint256 before);

    error UnableToBindNewAccountBefore(uint256 before);
}
