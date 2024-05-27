// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for Indexing Company Speedtracer track
contract IndexingCoThemeRenderer is
    SpeedtracerTheme(0xC0F779, 0x000000, 0x98F221, 0xF5F5F5)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Indexing Co";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "Indexing Company Track";
    }
}
