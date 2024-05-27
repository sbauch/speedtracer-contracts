// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for Rainbow Speedtracer track
contract RainbowThemeRenderer is
    SpeedtracerTheme(0x87E7FD, 0x10B3DD, 0x87E7FD, 0xFFFFFF)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Rainbow";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "Rainbow Road";
    }
}
