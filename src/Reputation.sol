// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "sismo-connect-solidity/SismoLib.sol"; // <--- add a Sismo Connect import

contract Reputation is SismoConnect {
    using SismoConnectHelper for SismoConnectVerifiedResult;

    event ReputationMapped(uint256 indexed vaultId, address indexed account, uint256 expiredAt);

    error UnableToBindBefore(uint256 before);

    //  address => vaultId bind an address to vaultId
    mapping(address => uint256) internal _accountToExpiredTime;

    mapping(uint256 => uint256) internal _vaultIdToRefreshTime;

    uint256 public immutable DURATION;

    bytes16 public immutable GROUP_ID;

    constructor(
        bytes16 appId,
        bytes16 dataGroupId,
        uint256 duration,
        bool isImpersonationMode

    ) SismoConnect(buildConfig(appId, isImpersonationMode)) {
        GROUP_ID = dataGroupId;
        DURATION = duration;
    }

    function bindReputation(
        address account,
        bytes memory proof
    ) public {
        AuthRequest[] memory auths = new AuthRequest[](1);
        auths[0] = buildAuth({authType: AuthType.VAULT});

        ClaimRequest[] memory claims = new ClaimRequest[](1);
        claims[0] = buildClaim({
            groupId: GROUP_ID,
            isSelectableByUser: false,
            isOptional: false
        });

        SismoConnectVerifiedResult memory result = verify({
            responseBytes: proof,
            auths: auths,
            claims: claims,
            signature: buildSignature({message: abi.encode(account)})
        });

        uint256 vaultId = result.getUserId(AuthType.VAULT);

        uint256 refreshTime = _vaultIdToRefreshTime[vaultId];
        if (refreshTime > block.timestamp) {
            revert UnableToBindBefore(refreshTime);
        }

        //
        uint256 expiredAt = block.timestamp + DURATION;
        _vaultIdToRefreshTime[vaultId] = expiredAt;
        _accountToExpiredTime[account] = expiredAt;
        emit ReputationMapped(vaultId, account, expiredAt);
    }

    // list
    function isInDataGroup(address account) external view returns (bool) {
        uint256 expiredAt = _accountToExpiredTime[account];
        return expiredAt > block.timestamp;
    }
}
