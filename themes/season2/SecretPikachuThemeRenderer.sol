// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for Metaversal track
contract SecretPikachuThemeRenderer is
    SpeedtracerTheme(0x909EB3, 0x5C5A58, 0x000000, 0xD9D9D9)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "SecretPikachu";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "Pika Place";
    }
}
