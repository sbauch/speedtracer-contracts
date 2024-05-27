// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for Stanley Cup track
contract StanleyCupThemeRenderer is
    SpeedtracerTheme(0x000000, 0x959DA1, 0x000000, 0xE4E5E6)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Stanley Cup";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "Stanley Circuit";
    }
}
