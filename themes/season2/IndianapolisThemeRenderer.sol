// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for Indianapolis Motor Speedway Road Course Speedtracer track
contract IndianapolisThemeRenderer is
    SpeedtracerTheme(0x605937, 0x000000, 0xCF9A1F, 0xFFFFFF)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Indianapolis Motor Speedway";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "Indy Road Course";
    }
}
