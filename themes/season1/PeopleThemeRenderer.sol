// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IThemeRenderer} from "../IThemeRenderer.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Desert Theme
/// @notice Colors, font and names for Desert themed Speedtracer tracks
contract PeopleThemeRenderer is IThemeRenderer {
    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    uint24 public constant BACKGROUND_COLOR = 0xF3EAB3;
    uint24 public constant KERB_COLOR = 0x0D3550;
    uint24 public constant ROAD_COLOR = 0xD0A955;
    uint24 public constant MIDLINE_COLOR = 0xF3EAB3;

    function themeColors() public pure returns (uint96) {
        return (uint96(BACKGROUND_COLOR) << 72) | (uint96(KERB_COLOR) << 48)
            | (uint96(ROAD_COLOR) << 24) | uint96(MIDLINE_COLOR);
    }

    function themeName() external pure returns (string memory) {
        return "PeopleDAO";
    }

    function name(uint256) external pure returns (string memory) {
        return "People's Park";
    }

    function background() external pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<rect id='bg' width='1200' height='1950' fill='#",
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
        // return FONT;
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
        '<filter id="noise"><feComponentTransfer><feFuncR type="identity" /><feFuncG type="identity" /><feFuncB type="identity" /><feFuncA type="identity" /></feComponentTransfer></filter><filter id="tf" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceGraphic" stdDeviation="2" result="blurred"></feGaussianBlur><feMerge><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /></feMerge></filter>';
    }
}
