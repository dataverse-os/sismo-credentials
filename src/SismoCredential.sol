// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "sismo-connect-solidity/SismoConnectLib.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {Events} from "./libraries/Events.sol";
import {Errors} from "./libraries/Errors.sol";
import {Ownable} from "./libraries/Ownable.sol";

contract SismoCredential is SismoConnect, Ownable {
    using SismoConnectHelper for SismoConnectVerifiedResult;

    /// @dev vaultId -> user account
    mapping(uint256 => DataTypes.Account) internal _bindingAccount;

    /// @dev account => dataGroupId => credential info
    mapping(address => mapping(bytes16 => DataTypes.CredentialInfo)) public getCredentialInfo;

    /// @dev groupId => group setting
    mapping(bytes16 => DataTypes.GroupSetup) public getGroupSetup;

    /// @notice after REFRESH_DURATION, user can bind a new account
    uint256 public immutable REFRESH_DURATION;

    bytes16[] internal _groupIds;

    constructor(
        address owner,
        bytes16 appId,
        uint256 duration,
        bool isImpersonationMode,
        DataTypes.GroupSetup[] memory groups
    ) Ownable(owner) SismoConnect(buildConfig(appId, isImpersonationMode)) {
        REFRESH_DURATION = duration;
        _addDataGroups(groups);
    }

    function getGroupIds() public view returns (bytes16[] memory) {
        return _groupIds;
    }

    function addDataGroups(DataTypes.GroupSetup[] memory _groups) public onlyOwner {
        _addDataGroups(_groups);
    }

    function deleteDataGroups(bytes16[] memory groupIds) public onlyOwner {
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
        if (acc.refreshAfter <= block.timestamp) {
            _clearPreviousBinding(acc.account);
            acc.account = account;
            acc.refreshAfter = block.timestamp + REFRESH_DURATION;
            _checkSismoCredential(account, result, vaultId);
            return;
        }

        _checkSismoCredential(acc.account, result, vaultId);
    }

    function _clearPreviousBinding(address _account) internal {
        uint256 len = _groupIds.length;
        for (uint256 i = 0; i < len; i++) {
            delete getCredentialInfo[_account][_groupIds[i]];
        }
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

    function _checkSismoCredential(address account, SismoConnectVerifiedResult memory result, uint256 vaultId)
        internal
    {
        for (uint256 i = 0; i < result.claims.length; i++) {
            VerifiedClaim memory verifiedClaim = result.claims[i];
            bytes16 groupId = verifiedClaim.groupId;

            DataTypes.GroupSetup memory group = getGroupSetup[groupId];
            DataTypes.CredentialInfo storage credentialInfo = getCredentialInfo[account][groupId];

            uint256 expiredAt = block.timestamp + group.duration - ((block.timestamp - group.startAt) % group.duration);

            credentialInfo.groupId = group.groupId;
            credentialInfo.value = true;
            credentialInfo.expiredAt = expiredAt;
            emit Events.CredentialMapped(vaultId, account, groupId, expiredAt);
        }
    }

    function _groupExist(bytes16 _groupId) internal view returns (bool) {
        return getGroupSetup[_groupId].groupId != bytes16(0);
    }
}
