// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IThemeRenderer} from "../IThemeRenderer.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Dot Dash Theme
/// @notice Colors, font and names for Dot Dash themed Speedtracer tracks
contract WeBuyTheArtThemeRenderer is IThemeRenderer {
    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    using Strings for uint256;

    uint24 public constant BACKGROUND_COLOR = 0x131313;
    uint24 public constant KERB_COLOR = 0xEC1C24;
    uint24 public constant ROAD_COLOR = 0x000000;
    uint24 public constant MIDLINE_COLOR = 0xD2B561;

    string public constant FONT =
        "url(data:font/woff2;base64,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) format('woff2')";

    function themeColors() public pure returns (uint96) {
        return (uint96(BACKGROUND_COLOR) << 72) | (uint96(KERB_COLOR) << 48)
            | (uint96(ROAD_COLOR) << 24) | uint96(MIDLINE_COLOR);
    }

    function themeName() external pure returns (string memory) {
        return "We Buy The Art";
    }

    function name(uint256) external pure returns (string memory) {
        return "Sunny Speedway";
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
        '<filter id="noise"><feComponentTransfer><feFuncR type="identity" /><feFuncG type="identity" /><feFuncB type="identity" /><feFuncA type="identity" /></feComponentTransfer></filter><filter id="tf" x="-50%" y="-50%" width="200%" height="200%"></filter><filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feFlood result="flood" flood-color="#ffffff" flood-opacity="1"></feFlood><feComposite in="flood" result="mask" in2="SourceGraphic" operator="in"></feComposite><feGaussianBlur in="mask" result="blurred" stdDeviation="1"></feGaussianBlur><feMerge><feMergeNode in="blurred"></feMergeNode><feMergeNode in="SourceGraphic"></feMergeNode></feMerge></filter><pattern id="grid" width="150" height="150" patternUnits="userSpaceOnUse"><path d="M 150 0 L 0 0 0 150" fill="none" stroke="#18181B" stroke-width="1"/></pattern>';
    }
}
