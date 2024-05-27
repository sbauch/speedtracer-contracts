// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IThemeRenderer} from "../IThemeRenderer.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Based Ghouls Theme
/// @notice Colors, font and names for Based Ghouls themed Speedtracer tracks
contract BasedGhoulsThemeRenderer is IThemeRenderer {
    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    uint24 public constant BACKGROUND_COLOR = 0x000000;
    uint24 public constant KERB_COLOR = 0xA3A3A3;
    uint24 public constant ROAD_COLOR = 0x000000;
    uint24 public constant MIDLINE_COLOR = 0xffffff;

    string public constant FONT =
        "url(data:font/woff2;base64,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) format('woff2')";

    function themeName() external pure returns (string memory) {
        return "Based Ghouls";
    }

    function name(uint256) external pure returns (string memory) {
        return "Based Ghouls Grand Prix";
    }

    function background() external pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<rect id='bg' width='100%' height='100%' fill='#",
                toHexString(BACKGROUND_COLOR),
                "' />"
            )
        );
    }

    function road() external pure returns (string memory) {
        return toHexString(ROAD_COLOR);
    }

    function kerb() external pure returns (string memory) {
        return toHexString(KERB_COLOR);
    }

    function midline() external pure returns (string memory) {
        return toHexString(MIDLINE_COLOR);
    }

    function font() external pure returns (string memory) {
        return FONT;
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(6);
        for (uint256 i = 0; i < 6; ++i) {
            buffer[5 - i] = SYMBOLS[value & 0xF];
            value >>= 4;
        }
        return string(buffer);
    }

    function filter(uint256) external pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<filter id="noise" filterUnits="userSpaceOnUse"><feTurbulence type="fractalNoise" baseFrequency="0.25" numOctaves="20" result="noise"/><feComposite in="SourceGraphic" in2="noise" operator="in"/></filter><filter id="inner-stroke" x="-50%" y="-50%" width="200%" height="200%"><feMorphology operator="dilate" radius="5" in="SourceAlpha" result="expanded"/><feFlood flood-color="black" result="color"/><feComposite in="color" in2="expanded" operator="in" result="inner-stroke"/><feComposite in="inner-stroke" in2="SourceAlpha" operator="in"/></filter><filter id="grass" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="2" result="noise" /><feDiffuseLighting in="noise" lighting-color="white" surfaceScale="1" result="diffuseLighting"><feDistantLight azimuth="45" elevation="55" /></feDiffuseLighting><feBlend in="SourceGraphic" in2="diffuseLighting" mode="multiply" /></filter>'
            )
        );
    }
}
