// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IThemeRenderer} from "../IThemeRenderer.sol";

/// @author sammybauch.eth
/// @title  Speedtracer 1kx Theme
/// @notice Colors, font and names for 1kx themed Speedtracer tracks
contract SocialGraphVenturesThemeRenderer is IThemeRenderer {
    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    uint24 public constant BACKGROUND_COLOR = 0xCBFD12;
    uint24 public constant KERB_COLOR = 0x0C0C0C;
    uint24 public constant ROAD_COLOR = 0xB7E310;
    uint24 public constant MIDLINE_COLOR = 0x0C0C0C;

    string public constant FONT =
        "url(data:font/ttf;utf-8;base64,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)";

    function themeColors() public pure returns (uint96) {
        return (uint96(BACKGROUND_COLOR) << 72) | (uint96(KERB_COLOR) << 48)
            | (uint96(ROAD_COLOR) << 24) | uint96(MIDLINE_COLOR);
    }

    function themeName() external pure returns (string memory) {
        return "Social Graph Ventures";
    }

    function name(uint256) external pure returns (string memory) {
        return "SGV Speedway";
    }

    function background() external pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<rect id='bg' width='100%' height='100%' fill='#",
                toHexString(BACKGROUND_COLOR),
                "' /> "
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
        '<filter id="noise"><feComponentTransfer><feFuncR type="identity" /><feFuncG type="identity" /><feFuncB type="identity" /><feFuncA type="identity" /></feComponentTransfer></filter><filter id="tf" x="-20%" y="-20%" width="140%" height="140%"></filter>';
    }
}
