// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "sismo-connect-solidity/SismoLib.sol";

contract Reputations is SismoConnect {
    using SismoConnectHelper for SismoConnectVerifiedResult;

    event ReputationMapped(
        uint256 indexed vaultId, address indexed account, bytes16 indexed groupId, uint256 expiredAt
    );

    struct Account {
        address account;
        uint256 refreshAfter;
    }

    struct Reputation {
        bytes16 groupId;
        bool value;
        uint256 expiredAt;
    }

    struct GroupSetup {
        uint256 startAt;
        bytes16 groupId;
        uint256 duration;
    }

    /// @dev mapping vaultId -> user account
    mapping(uint256 => Account) internal _bindingAccount;

    /// binding account => dataGroupId => reputation Info
    mapping(address => mapping(bytes16 => Reputation)) public reputations;

    /// @dev groupId to group setting
    mapping(bytes16 => GroupSetup) public groupSetups;

    /// @dev after REFRESH_DURATION, user can bind a new account
    uint256 public immutable REFRESH_DURATION;

    bytes16[] public groupIds;

    error UnableToBindBefore(uint256 before);

    error UnableToBindNewAccountBefore(uint256 before);

    constructor(bytes16 appId, uint256 duration, bool isImpersonationMode, GroupSetup[] memory groups)
        SismoConnect(buildConfig(appId, isImpersonationMode))
    {
        REFRESH_DURATION = duration;

        for (uint256 i; i < groups.length; i++) {
            groupSetups[groups[i].groupId] = groups[i];
            groupIds.push(groups[i].groupId);
        }
    }

    function bindReputation(address account, bytes memory proof) public {
        require(account != address(0), "Invalid address");

        AuthRequest[] memory auths = new AuthRequest[](1);
        auths[0] = buildAuth({authType: AuthType.VAULT});

        uint256 len = groupIds.length;
        ClaimRequest[] memory claims = new ClaimRequest[](len);
        for (uint256 i; i < len; i++) {
            claims[i] = buildClaim({groupId: groupIds[i], isSelectableByUser: false, isOptional: true});
        }

        SismoConnectVerifiedResult memory result = verify({
            responseBytes: proof,
            auths: auths,
            claims: claims,
            signature: buildSignature({message: abi.encode(account)})
        });

        uint256 vaultId = result.getUserId(AuthType.VAULT);
        Account storage acc = _bindingAccount[vaultId];
        /// todo: account 更新时间 和 声誉失效时间 有重叠
        if (acc.refreshAfter < block.timestamp) {
            acc.account = account;
            acc.refreshAfter = block.timestamp + REFRESH_DURATION;
            _checkReputation(account, result, vaultId);
            return;
        }
    }

    function reputationDetail(address account) external view returns (Reputation[] memory) {
        uint256 len = groupIds.length;
        Reputation[] memory infos = new Reputation[](len);
        for (uint256 i = 0; i < len; i++) {
            Reputation memory r = reputations[account][groupIds[i]];
            infos[i] = r;
        }
        return infos;
    }

    function _checkReputation(address account, SismoConnectVerifiedResult memory result, uint256 vaultId) internal {
        for (uint256 i = 0; i < result.claims.length; i++) {
            VerifiedClaim memory verifiedClaim = result.claims[i];
            bytes16 groupId = verifiedClaim.groupId;

            GroupSetup memory group = groupSetups[groupId];
            Reputation storage reputation = reputations[account][groupId];

            uint256 expiredAt = block.timestamp + group.duration - ((block.timestamp - group.startAt) % group.duration);

            reputation.groupId = group.groupId;
            reputation.value = true;
            reputation.expiredAt = expiredAt;
            emit ReputationMapped(vaultId, account, groupId, expiredAt);
        }
    }
}
