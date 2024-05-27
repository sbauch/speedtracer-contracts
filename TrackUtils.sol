// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {Math} from "openzeppelin/contracts/utils/math/Math.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

contract TrackUtils {
    using Strings for uint256;

    uint64 private constant PRIME1 = 1572869;
    uint64 private constant PRIME2 = 29996224275833;

    struct Point {
        int256 x;
        int256 y;
    }

    function pseudoRandom(uint256 seed) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(seed))) % PRIME2;
    }

    function nextRandom(uint256 seed) internal pure returns (uint256) {
        return (seed * PRIME1) % PRIME2;
    }

    function abs(int256 x) internal pure returns (uint256) {
        return x >= 0 ? uint256(x) : uint256(x * -1);
    }

    function clamp(int256 value, int256 minValue, int256 maxValue)
        internal
        pure
        returns (int256)
    {
        return min(max(value, minValue), maxValue);
    }

    function minDistanceBetweenPoints(Point memory a, Point memory b)
        internal
        pure
        returns (uint256)
    {
        int256 dx = int256(a.x) - int256(b.x);
        int256 dy = int256(a.y) - int256(b.y);
        return uint256(min(abs(dx), abs(dy)));
    }

    function maxDistanceBetweenPoints(Point memory a, Point memory b)
        internal
        pure
        returns (uint256)
    {
        int256 dx = int256(a.x) - int256(b.x);
        int256 dy = int256(a.y) - int256(b.y);
        return uint256(max(abs(dx), abs(dy)));
    }

    function distanceBetweenPoints(Point memory a, Point memory b)
        internal
        pure
        returns (uint256)
    {
        int256 dx = int256(a.x) - int256(b.x);
        int256 dy = int256(a.y) - int256(b.y);
        return sqrt(uint256(dx * dx + dy * dy));
    }

    function max(int256 a, int256 b) internal pure returns (int256) {
        return a >= b ? a : b;
    }

    function min(int256 a, int256 b) internal pure returns (int256) {
        return a <= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (int256) {
        return a < b ? int256(a) : int256(b);
    }

    function max(uint256 a, uint256 b) internal pure returns (int256) {
        return a > b ? int256(a) : int256(b);
    }

    function sqrt(uint256 x) internal pure returns (uint256) {
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    function intString(int256 n) internal pure returns (string memory) {
        if (n == 0) {
            return "0";
        }
        if (n > 0) {
            return uint256(n).toString();
        }

        return string(abi.encodePacked("-", uint256(n * -1).toString()));
    }
}
