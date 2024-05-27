// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {LibString} from "solady/src/utils/LibString.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Cyberpunk Theme
/// @notice Colors, font and names for Cyberpunk themed Speedtracer tracks
contract CyberpunkRenderer is
    SpeedtracerTheme(0x0F2041, 0x0F2041, 0xD56C8C, 0xE883A0)
{
    constructor(address font) {
        setFontAddress(font);
    }

    string[] private prefixes = [
        "2030",
        "",
        "New",
        "",
        "",
        "Tech",
        "Night",
        "",
        "",
        "National",
        "",
        "Global",
        ""
    ];
    string[] private cities = [
        "Japan",
        "Korea",
        "Tokyo",
        "Seoul",
        "Singapore",
        "Beijing",
        "Taiwan",
        "Taipei",
        "Shanghai",
        "Hong Kong"
    ];

    string[] private suffixes = [
        "Circuit",
        "Street Circuit",
        "City Circuit",
        "Track",
        "Raceway",
        "Park",
        "Motorway",
        "Speedway",
        "Motorplex",
        "Motorpark",
        "Motor Sport Park",
        "Racecourse",
        "Racing Circuit",
        "TT Circuit",
        "Street Race",
        "Drift Course",
        "Drift Circuit"
    ];

    function themeName() external view override returns (string memory) {
        return "Cyberpunk";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory trackName)
    {
        uint256 prefixIndex = tokenId % prefixes.length;
        uint256 cityIndex = tokenId % cities.length;
        uint256 suffixIndex = tokenId % suffixes.length;
        trackName = string(
            abi.encodePacked(
                prefixes[prefixIndex],
                " ",
                cities[cityIndex],
                " ",
                suffixes[suffixIndex]
            )
        );

        if (LibString.runeCount(trackName) > 21) {
            trackName = string(
                abi.encodePacked(cities[cityIndex], " ", suffixes[suffixIndex])
            );
        }
    }

    function background() external view override returns (string memory) {
        return string(
            abi.encodePacked(
                "<rect id='bg' width='1200' height='1950' fill='#",
                toHexString(BACKGROUND_COLOR),
                "' />  <rect x='30' y='30' width='1140' height='1890' fill='url(#grid)' filter='url(#glow)' stroke-width='1' stroke='#D56C8C' />"
            )
        );
    }

    function filter(uint256) external view override returns (string memory) {
        return
        '<filter id="noise" filterUnits="userSpaceOnUse"><feTurbulence type="fractalNoise" baseFrequency="0.25" numOctaves="20" result="noise"/><feComposite in="SourceGraphic" in2="noise" operator="in"/></filter><filter id="tf" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceGraphic" stdDeviation="2" result="blurred"></feGaussianBlur><feMerge><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /></feMerge></filter><filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feFlood result="flood" flood-color="#d76095" flood-opacity="1"></feFlood><feComposite in="flood" result="mask" in2="SourceGraphic" operator="in"></feComposite><feGaussianBlur in="mask" result="blurred" stdDeviation="1"></feGaussianBlur><feMerge><feMergeNode in="blurred"></feMergeNode><feMergeNode in="SourceGraphic"></feMergeNode></feMerge></filter><pattern id="grid" width="30" height="30" patternUnits="userSpaceOnUse"><path d="M 30 0 L 0 0 0 30" fill="none" stroke="#D56C8C" stroke-width="1"/></pattern>';
    }
}
