// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IThemeRenderer} from "../IThemeRenderer.sol";

/// @author sammybauch.eth
contract RGBThemeRenderer is IThemeRenderer {
    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    uint24 public constant BACKGROUND_COLOR = 0x000000;
    uint24 public constant KERB_COLOR = 0x0000FF;
    uint24 public constant ROAD_COLOR = 0x000000;
    uint24 public constant MIDLINE_COLOR = 0xFFFFFF;

    string public constant FONT =
        "url(data:font/woff2;base64,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) format('woff2')";

    function themeColors() public pure returns (uint96) {
        return (uint96(BACKGROUND_COLOR) << 72) | (uint96(KERB_COLOR) << 48)
            | (uint96(ROAD_COLOR) << 24) | uint96(MIDLINE_COLOR);
    }

    function themeName() external pure returns (string memory) {
        return "RGB";
    }

    function name(uint256) external pure returns (string memory) {
        return "RGB Raceway";
    }

    function background() external pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<rect id='bg' width='100%' height='100%' fill='#",
                toHexString(BACKGROUND_COLOR),
                "' />"
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
        '<filter id="noise"><feComponentTransfer><feFuncR type="identity" /><feFuncG type="identity" /><feFuncB type="identity" /><feFuncA type="identity" /></feComponentTransfer></filter><filter id="tf" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="2 2" result="shadow"/><feOffset dx="2" dy="2"/></filter>';
    }
}