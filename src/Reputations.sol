// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "sismo-connect-solidity/SismoLib.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {Events} from "./libraries/Events.sol";
import {Errors} from "./libraries/Errors.sol";

contract Reputations is SismoConnect, Ownable {
    using SismoConnectHelper for SismoConnectVerifiedResult;

    /// @dev mapping vaultId -> user account
    mapping(uint256 => DataTypes.Account) internal _bindingAccount;

    /// binding account => dataGroupId => reputation Info
    mapping(address => mapping(bytes16 => DataTypes.Reputation)) public reputations;

    /// @dev groupId to group setting
    mapping(bytes16 => DataTypes.GroupSetup) public groupSetups;

    /// @dev after REFRESH_DURATION, user can bind a new account
    uint256 public immutable REFRESH_DURATION;

    bytes16[] public groupIds;

    constructor(bytes16 appId, uint256 duration, bool isImpersonationMode, DataTypes.GroupSetup[] memory groups)
        SismoConnect(buildConfig(appId, isImpersonationMode))
    {
        REFRESH_DURATION = duration;

        for (uint256 i; i < groups.length; i++) {
            groupSetups[groups[i].groupId] = groups[i];
            groupIds.push(groups[i].groupId);
        }
    }

    function addDataGroups(DataTypes.GroupSetup[] memory _groups) public onlyOwner {}

    function deleteDataGroups(bytes16[] memory _groupIds) public onlyOwner {}

    function bindReputation(address account, bytes memory proof) public {
        if (account == address(0)) {
            revert Errors.InvalidAddress();
        }

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
        DataTypes.Account storage acc = _bindingAccount[vaultId];
        /// todo: account 更新时间 和 声誉失效时间 有重叠
        if (acc.refreshAfter < block.timestamp) {
            acc.account = account;
            acc.refreshAfter = block.timestamp + REFRESH_DURATION;
            _checkReputation(account, result, vaultId);
            return;
        }
    }

    function reputationDetail(address account) external view returns (DataTypes.Reputation[] memory) {
        uint256 len = groupIds.length;
        DataTypes.Reputation[] memory infos = new DataTypes.Reputation[](len);
        for (uint256 i = 0; i < len; i++) {
            DataTypes.Reputation memory r = reputations[account][groupIds[i]];
            infos[i] = r;
        }
        return infos;
    }

    function _checkReputation(address account, SismoConnectVerifiedResult memory result, uint256 vaultId) internal {
        for (uint256 i = 0; i < result.claims.length; i++) {
            VerifiedClaim memory verifiedClaim = result.claims[i];
            bytes16 groupId = verifiedClaim.groupId;

            DataTypes.GroupSetup memory group = groupSetups[groupId];
            DataTypes.Reputation storage reputation = reputations[account][groupId];

            uint256 expiredAt = block.timestamp + group.duration - ((block.timestamp - group.startAt) % group.duration);

            reputation.groupId = group.groupId;
            reputation.value = true;
            reputation.expiredAt = expiredAt;
            emit Events.ReputationMapped(vaultId, account, groupId, expiredAt);
        }
    }
}
