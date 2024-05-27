// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for Based Onchain Dinos track
contract DinosThemeRenderer is
    SpeedtracerTheme(0x99CCFF, 0xE37931, 0xE1D8D1, 0xF4F4F4)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Based OnChain Dinos";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "RAWR Raceway";
    }
}
