// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for UCL track
contract UCLThemeRenderer is
    SpeedtracerTheme(0x000636, 0xC60EF8, 0x000636, 0x0015FE)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "UEFA Champions League";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "Champions Circuit";
    }
}
