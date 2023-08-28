// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "sismo-connect-solidity/SismoLib.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {Events} from "./libraries/Events.sol";
import {Errors} from "./libraries/Errors.sol";

import "forge-std/console.sol";

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
        _addDataGroups(groups);
    }

    function addDataGroups(DataTypes.GroupSetup[] memory _groups) public onlyOwner {
        _addDataGroups(_groups);
    }

    function deleteDataGroups(bytes16[] memory _groupIds) public onlyOwner {
        console.log("input length: ", _groupIds.length);
        for (uint256 i; i < _groupIds.length; i++) {
            uint256 len = groupIds.length;
            console.log("groupIds.length: ", groupIds.length);

            for (uint256 j; j < len; j++) {
                if (groupIds[j] == _groupIds[i]) {
                    console.log("i:", i);
                    console.log("j:", j);
                    console.log("groupIds[j] ");
                    console.logBytes16(groupIds[j]);
                    console.log("_groupIds[i] ");
                    console.logBytes16(_groupIds[i]);
                    groupIds[j] = groupIds[len - 1];
                    groupIds.pop();
                    //                    delete groupIds[len - 1];
                    console.log("groupIds.length", groupIds.length);
                    delete groupSetups[_groupIds[i]];
                    emit Events.ReputationRemoved(_groupIds[i], block.timestamp);
                    break;
                }
            }
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
        DataTypes.Account storage acc = _bindingAccount[vaultId];
        if (acc.refreshAfter <= block.timestamp) {
            _clearPreviousBinding(acc.account);
            acc.account = account;
            acc.refreshAfter = block.timestamp + REFRESH_DURATION;
            _checkReputation(account, result, vaultId);
            return;
        }

        _checkReputation(acc.account, result, vaultId);
    }

    function _clearPreviousBinding(address _account) internal {
        uint256 len = groupIds.length;
        for (uint256 i = 0; i < len; i++) {
            delete reputations[_account][groupIds[i]];
        }
    }

    function reputationDetail(address account) external view returns (DataTypes.Reputation[] memory) {
        uint256 len = groupIds.length;
        DataTypes.Reputation[] memory infos = new DataTypes.Reputation[](len);
        for (uint256 i = 0; i < len; i++) {
            DataTypes.Reputation memory r = reputations[account][groupIds[i]];
            if (r.expiredAt < block.timestamp) {
                r.value = false;
            }
            infos[i] = r;
        }
        return infos;
    }

    function reputationNumber() external view returns (uint256) {
        return groupIds.length;
    }

    function _addDataGroups(DataTypes.GroupSetup[] memory _groups) internal {
        for (uint256 i; i < _groups.length; i++) {
            bytes16 groupId = _groups[i].groupId;

            if (_groupExist(groupId)) {
                continue;
            }

            groupSetups[groupId] = _groups[i];
            groupIds.push(groupId);
            emit Events.ReputationAdded(groupId, block.timestamp);
        }
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

    function _groupExist(bytes16 _groupId) internal view returns (bool) {
        return groupSetups[_groupId].groupId != bytes16(0);
    }
}
