// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for Dotfan Speedtracer track
contract DotfanThemeRenderer is
    SpeedtracerTheme(0x0C1013, 0xFE0007, 0xFC394D, 0xffffff)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Dotfan";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return "Dot Dash";
    }

    function background() external view override returns (string memory) {
        return string(
            abi.encodePacked(
                "<rect id='bg' width='1200' height='1950' fill='#",
                toHexString(BACKGROUND_COLOR),
                "' />  <rect x='0' y='0' width='1200' height='1950' fill='url(#grid)' filter='url(#glow)' stroke-width='2' stroke='#0C1013' />"
            )
        );
    }

    function filter(uint256 id)
        external
        view
        override
        returns (string memory)
    {
        return
        '<filter id="noise" filterUnits="userSpaceOnUse"><feTurbulence type="fractalNoise" baseFrequency="0.25" numOctaves="20" result="noise"/><feComposite in="SourceGraphic" in2="noise" operator="in"/></filter><filter id="tf" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceGraphic" stdDeviation="2" result="blurred"></feGaussianBlur><feMerge><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /></feMerge></filter><filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feFlood result="flood" flood-color="#ffffff" flood-opacity="1"></feFlood><feComposite in="flood" result="mask" in2="SourceGraphic" operator="in"></feComposite><feGaussianBlur in="mask" result="blurred" stdDeviation="1"></feGaussianBlur><feMerge><feMergeNode in="blurred"></feMergeNode><feMergeNode in="SourceGraphic"></feMergeNode></feMerge></filter><pattern id="grid" width="150" height="150" patternUnits="userSpaceOnUse"><path d="M 150 0 L 0 0 0 150" fill="none" stroke="#18181B" stroke-width="1"/></pattern>';
    }
}
