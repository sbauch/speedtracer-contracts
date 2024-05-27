// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Desert Theme
/// @notice Colors, font and names for Desert themed Speedtracer tracks
contract DesertThemeRenderer is
    SpeedtracerTheme(0xfcf3cc, 0xaf7c54, 0xd6b484, 0xe9c9a1)
{
    string[] private prefixes = [
        "New",
        "Historic",
        "Prince of",
        "King of",
        "",
        "Princess of",
        "Queen of",
        "Royal",
        "Grand",
        "",
        "International",
        "Global",
        "",
        "Classic",
        "National",
        ""
    ];
    string[] private cities = [
        "Bahrain",
        "Baku",
        "Abu Dhabi",
        "Lusail",
        "Jeddah",
        "Yas Marina",
        "Ain-Diab",
        "Cairo",
        "Riyadh",
        "Dubai",
        "Doha",
        "Muscat",
        "Amman"
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
        "Raceway Park"
    ];

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Desert";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        uint256 prefixIndex = tokenId % prefixes.length;
        uint256 cityIndex = tokenId % cities.length;
        uint256 suffixIndex = tokenId % suffixes.length;
        return string(
            abi.encodePacked(
                prefixes[prefixIndex],
                " ",
                cities[cityIndex],
                " ",
                suffixes[suffixIndex]
            )
        );
    }

    function background() external pure override returns (string memory) {
        return
        '<rect width="1200" height="1950" style="stroke:#af7c54; stroke-width:36;" fill="#fcf3cc" filter="url(#sandTexture)" />';
    }

    function filter(uint256) external pure override returns (string memory) {
        return
        '<filter id="noise" filterUnits="userSpaceOnUse"><feTurbulence type="fractalNoise" baseFrequency="0.25" numOctaves="20" result="noise"/><feComposite in="SourceGraphic" in2="noise" operator="in"/></filter><filter id="tf" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="2 2" result="shadow"/><feOffset dx="4" dy="4"/></filter> <filter id="sandTexture" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="2" result="noise" /><feDiffuseLighting in="noise" lighting-color="white" surfaceScale="1" result="diffuseLighting"><feDistantLight azimuth="45" elevation="55" /></feDiffuseLighting><feBlend in="SourceGraphic" in2="diffuseLighting" mode="multiply" /></filter>';
    }
}
