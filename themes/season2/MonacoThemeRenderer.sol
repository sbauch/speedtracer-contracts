// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for F1 Monaco Speedtracer track
contract MonacoThemeRenderer is
    SpeedtracerTheme(0xEF4222, 0x000000, 0xFFFFFF, 0xEF4222)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "F1: Monaco";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "Circuit de Monaco";
    }

    function filter(uint256 id)
        external
        view
        override
        returns (string memory)
    {
        return string(
            abi.encodePacked(
                '<filter id="tf" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="2 2" result="shadow"/><feOffset dx="2" dy="2"/></filter>'
            )
        );
    }
}
