// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "sismo-connect-solidity/SismoConnectLib.sol";
import {EnumerableSet} from "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {Events} from "./libraries/Events.sol";
import {Errors} from "./libraries/Errors.sol";

contract SismoCredential is SismoConnect, Ownable {
    using SismoConnectHelper for SismoConnectVerifiedResult;

    /**
     * @dev vaultId => user account
     */
    mapping(uint256 => DataTypes.Account) internal _bindingAccount;

    /**
     * @dev account => dataGroupId => credential info
     */
    mapping(address => mapping(bytes16 => DataTypes.CredentialInfo)) public getCredentialInfo;

    /**
     * @dev groupId => group setting
     */
    mapping(bytes16 => DataTypes.GroupSetup) public getGroupSetup;

    /**
     * @dev after _refreshDuration, user can bind a new account
     */
    uint256 internal _refreshDuration;

    bytes16[] internal _groupIds;

    constructor(
        address owner,
        bytes16 appId,
        uint256 refreshDuration,
        bool isImpersonationMode,
        DataTypes.GroupSetup[] memory groups
    ) SismoConnect(buildConfig(appId, isImpersonationMode)) {
        _transferOwnership(owner);
        _setRefreshDuration(refreshDuration);
        _addDataGroups(groups);
    }

    function getRefreshDuration() public view returns (uint256) {
        return _refreshDuration;
    }

    function setRefreshDuration(uint256 refreshDuration) public onlyOwner {
        _setRefreshDuration(refreshDuration);
    }

    function addDataGroups(DataTypes.GroupSetup[] memory _groups) public onlyOwner {
        _addDataGroups(_groups);
    }

    function deleteDataGroups(bytes16[] memory groupIds) public onlyOwner {
        _deleteDataGroups(groupIds);
    }

    function getGroupIds() public view returns (bytes16[] memory) {
        return _groupIds;
    }

    function bindCredential(address account, bytes memory proof) public {
        if (account == address(0)) {
            revert Errors.InvalidAddress();
        }

        AuthRequest[] memory auths = new AuthRequest[](1);
        auths[0] = buildAuth({authType: AuthType.VAULT});

        uint256 len = _groupIds.length;
        ClaimRequest[] memory claims = new ClaimRequest[](len);
        for (uint256 i; i < len; i++) {
            claims[i] = buildClaim({groupId: _groupIds[i], isSelectableByUser: false, isOptional: true});
        }

        SismoConnectVerifiedResult memory result = verify({
            responseBytes: proof,
            auths: auths,
            claims: claims,
            signature: buildSignature({message: abi.encode(account)})
        });

        uint256 vaultId = result.getUserId(AuthType.VAULT);
        DataTypes.Account storage acc = _bindingAccount[vaultId];
        if (acc.refreshAfter > block.timestamp) {
            revert Errors.RefreshDurationNotOver(acc.refreshAfter - block.timestamp);
        }
        _deleteCredentialInfo(acc.account);
        acc.account = account;
        acc.refreshAfter = block.timestamp + _refreshDuration;
        _updateCredentialInfo(account, result, vaultId);
    }

    function getCredentialInfoList(address account) external view returns (DataTypes.CredentialInfo[] memory) {
        uint256 len = _groupIds.length;
        DataTypes.CredentialInfo[] memory infos = new DataTypes.CredentialInfo[](len);
        for (uint256 i = 0; i < len; i++) {
            DataTypes.CredentialInfo memory r = getCredentialInfo[account][_groupIds[i]];
            if (r.expiredAt < block.timestamp) {
                r.value = false;
            }
            infos[i] = r;
            infos[i].groupId = _groupIds[i];
        }
        return infos;
    }

    function _setRefreshDuration(uint256 refreshDuration) internal {
        _refreshDuration = refreshDuration;
        emit Events.RefreshDurationSet(refreshDuration);
    }

    function _addDataGroups(DataTypes.GroupSetup[] memory _groups) internal {
        for (uint256 i; i < _groups.length; i++) {
            bytes16 groupId = _groups[i].groupId;

            if (_groupExist(groupId)) {
                continue;
            }

            getGroupSetup[groupId] = _groups[i];
            _groupIds.push(groupId);
            emit Events.CredentialAdded(groupId, block.timestamp);
        }
    }

    function _deleteDataGroups(bytes16[] memory groupIds) internal {
        for (uint256 i; i < groupIds.length; i++) {
            uint256 len = _groupIds.length;
            for (uint256 j; j < len; j++) {
                if (_groupIds[j] == groupIds[i]) {
                    _groupIds[j] = _groupIds[len - 1];
                    _groupIds.pop();
                    delete getGroupSetup[groupIds[i]];
                    emit Events.CredentialRemoved(groupIds[i], block.timestamp);
                    break;
                }
            }
        }
    }

    function _updateCredentialInfo(address account, SismoConnectVerifiedResult memory result, uint256 vaultId)
        internal
    {
        for (uint256 i = 0; i < result.claims.length; i++) {
            VerifiedClaim memory verifiedClaim = result.claims[i];
            bytes16 groupId = verifiedClaim.groupId;

            DataTypes.GroupSetup memory groupSetup = getGroupSetup[groupId];
            DataTypes.CredentialInfo storage credentialInfo = getCredentialInfo[account][groupId];

            uint256 expiredAt =
                block.timestamp + groupSetup.duration - ((block.timestamp - groupSetup.startAt) % groupSetup.duration);

            credentialInfo.groupId = groupSetup.groupId;
            credentialInfo.value = true;
            credentialInfo.expiredAt = expiredAt;
            emit Events.CredentialMapped(vaultId, account, groupId, expiredAt);
        }
    }

    function _deleteCredentialInfo(address _account) internal {
        uint256 len = _groupIds.length;
        for (uint256 i = 0; i < len; i++) {
            delete getCredentialInfo[_account][_groupIds[i]];
        }
    }

    function _groupExist(bytes16 _groupId) internal view returns (bool) {
        return getGroupSetup[_groupId].groupId != bytes16(0);
    }
}
