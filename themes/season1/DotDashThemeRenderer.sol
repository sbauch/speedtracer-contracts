// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IThemeRenderer} from "../IThemeRenderer.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Dot Dash Theme
/// @notice Colors, font and names for Dot Dash themed Speedtracer tracks
contract DotDashThemeRenderer is IThemeRenderer {
    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    using Strings for uint256;

    uint24 public constant BACKGROUND_COLOR = 0x0C1013;
    uint24 public constant KERB_COLOR = 0xFE0007;
    uint24 public constant ROAD_COLOR = 0xFC394D;
    uint24 public constant MIDLINE_COLOR = 0xffffff;

    string public constant FONT =
        "url(data:font/woff2;base64,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) format('woff2');";

    function themeColors() public pure returns (uint96) {
        return (uint96(BACKGROUND_COLOR) << 72) | (uint96(KERB_COLOR) << 48)
            | (uint96(ROAD_COLOR) << 24) | uint96(MIDLINE_COLOR);
    }

    function themeName() external pure returns (string memory) {
        return "Dot Dash";
    }

    function name(uint256) external pure returns (string memory) {
        return "The Dot Dash";
    }

    function background() external pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<rect id='bg' width='1200' height='1950' fill='#",
                toHexString(BACKGROUND_COLOR),
                "' />  <rect x='0' y='0' width='1200' height='1950' fill='url(#grid)' filter='url(#glow)' stroke-width='1' stroke='#0C1013' />"
            )
        );
    }

    function road() external pure returns (string memory) {
        return toHexString(ROAD_COLOR);
    }

    function kerb() external pure returns (string memory) {
        return toHexString(KERB_COLOR);
    }

    function midline() external pure returns (string memory) {
        return toHexString(MIDLINE_COLOR);
    }

    function font() external pure returns (string memory) {
        return FONT;
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(6);
        for (uint256 i = 0; i < 6; ++i) {
            buffer[5 - i] = SYMBOLS[value & 0xF];
            value >>= 4;
        }
        return string(buffer);
    }

    function filter(uint256) external pure returns (string memory) {
        return
        '<filter id="noise" filterUnits="userSpaceOnUse"><feTurbulence type="fractalNoise" baseFrequency="0.25" numOctaves="20" result="noise"/><feComposite in="SourceGraphic" in2="noise" operator="in"/></filter><filter id="tf" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceGraphic" stdDeviation="2" result="blurred"></feGaussianBlur><feMerge><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /></feMerge></filter><filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feFlood result="flood" flood-color="#ffffff" flood-opacity="1"></feFlood><feComposite in="flood" result="mask" in2="SourceGraphic" operator="in"></feComposite><feGaussianBlur in="mask" result="blurred" stdDeviation="1"></feGaussianBlur><feMerge><feMergeNode in="blurred"></feMergeNode><feMergeNode in="SourceGraphic"></feMergeNode></feMerge></filter><pattern id="grid" width="150" height="150" patternUnits="userSpaceOnUse"><path d="M 150 0 L 0 0 0 150" fill="none" stroke="#18181B" stroke-width="1"/></pattern>';
    }
}
