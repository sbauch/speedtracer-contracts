// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for Basepaint Speedtracer track
contract BasepaintThemeRenderer is
    SpeedtracerTheme(0x583B55, 0x000000, 0x583B55, 0xE7D9B3)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Basepaint";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "Basepaint Super Circuit";
    }
}
