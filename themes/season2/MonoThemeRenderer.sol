// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Mono Theme
/// @notice Colors, font and names for Mono themed Speedtracer tracks
contract MonoThemeRenderer is
    SpeedtracerTheme(0xf5f5f5, 0x2b2b2b, 0xf5f5f5, 0x2b2b2b)
{
    string[] private names = [
        "Paper Trail",
        "BW Circuit",
        "Mono Motorpark",
        "Grayscale Speedway",
        "Ink Street Track"
    ];

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Monochrome";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        uint256 index = tokenId % names.length;
        return names[index];
    }
}
