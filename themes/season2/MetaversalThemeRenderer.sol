// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for Metaversal track
contract MetaversalThemeRenderer is
    SpeedtracerTheme(0x311311, 0xEC1B23, 0x4C2580, 0xDFD618)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Metaversal";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "Metaversal Motorway";
    }
}
