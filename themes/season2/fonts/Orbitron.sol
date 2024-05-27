// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IFont} from "./IFont.sol";
/// @author sammybauch.eth
/// @title  Speedtracer Theme Renderer Interface
/// @notice Track renderer calls theme for colors, font and name

contract Orbitron is IFont {
    function name() external pure returns (string memory) {
        return "Orbitron";
    }

    function font() external pure returns (string memory) {
        return
        "url(data:font/woff2;base64,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) format('woff2')";
    }
}
