
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Utils {
    function bytes16ToHexString(
        bytes16 _bytes16
    ) public pure returns (string memory) {
        bytes memory hexString = new bytes(32);
        for (uint256 i = 0; i < 16; i++) {
            uint8 nibble1 = uint8(_bytes16[i]) >> 4;
            uint8 nibble2 = uint8(_bytes16[i]) & 0x0F;
            hexString[i * 2] = nibbleToHexChar(nibble1);
            hexString[i * 2 + 1] = nibbleToHexChar(nibble2);
        }
        return string(hexString);
    }

    function nibbleToHexChar(uint8 nibble) private pure returns (bytes1) {
        if (nibble < 10) {
            return bytes1(uint8(nibble) + 48); // 48 represents '0' in ASCII
        } else {
            return bytes1(uint8(nibble) + 87); // 87 represents 'a' in ASCII
        }
    }

    function concatStrings(
        string memory _str1,
        string memory _str2
    ) public pure returns (string memory) {
        bytes memory str1Bytes = bytes(_str1);
        bytes memory str2Bytes = bytes(_str2);
        bytes memory result = new bytes(str1Bytes.length + str2Bytes.length);

        uint256 k = 0;
        for (uint256 i = 0; i < str1Bytes.length; i++) {
            result[k++] = str1Bytes[i];
        }

        for (uint256 j = 0; j < str2Bytes.length; j++) {
            result[k++] = str2Bytes[j];
        }

        return string(result);
    }
}