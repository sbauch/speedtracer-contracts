// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";
import {LibString} from "solady/src/utils/LibString.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Nordic Theme
/// @notice Colors, font and names for Nordic themed Speedtracer tracks
contract NordicThemeRenderer is
    SpeedtracerTheme(0xe9faff, 0x6e8291, 0xacdbdf, 0xc8e8ed)
{
    using Strings for uint256;

    string[] private prefixes = [
        "Great",
        "Wild",
        "",
        "New",
        "Modern",
        "Old",
        "Classic",
        "Historic",
        "Famous",
        "",
        "Grand",
        "Majestic",
        "",
        "Royal",
        "Imperial",
        "Regal",
        "Noble"
    ];
    string[] private cities = [
        "Stockholm",
        "Copenhagen",
        "Helsinki",
        unicode"Malmö",
        "Oslo",
        unicode"Reykjavík",
        "Toronto",
        "Vancouver",
        "Alaskan",
        "Scandinavian",
        "Canadian"
    ];
    string[] private suffixes = [
        "Circuit",
        "Ring",
        "City Circuit",
        "Track",
        "Raceway",
        "Park",
        "Motorway",
        "Speedway",
        "Motorbana",
        "Motorpark",
        "Motor Sport Park",
        "Racecourse",
        "Arena",
        "TT Circuit",
        "Racing Line",
        "Raceway Park",
        "Racing Club"
    ];

    constructor(address font) {
        setFontAddress(font);
    }

    function themeName() external pure override returns (string memory) {
        return "Nordic";
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
        return
        "<rect id='bg' width='1200' height='1950' style='stroke:#F9D276; stroke-width:36;' fill='url(#bg-g)' filter='url(#bg-f)' />";
    }

    function filter(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        return string(
            abi.encodePacked(
                '<filter id="noise" filterUnits="userSpaceOnUse"><feTurbulence type="fractalNoise" baseFrequency="0.25" numOctaves="20" result="noise"/><feComposite in="SourceGraphic" in2="noise" operator="in"/></filter><filter id="tf" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="2 2" result="shadow"/><feOffset dx="4" dy="4"/></filter><linearGradient gradientTransform="rotate(30, 0.5, 0.5)" x1="0%" y1="0%" x2="100%" y2="100%" id="bg-g"><stop stop-color="#9dcfde" stop-opacity="1" offset="0%"></stop><stop stop-color="#e9faff" stop-opacity="1" offset="100%"></stop></linearGradient><filter id="bg-f" x="-20%" y="-20%" width="140%" height="140%" filterUnits="objectBoundingBox" primitiveUnits="userSpaceOnUse" color-interpolation-filters="sRGB"><feTurbulence type="fractalNoise" baseFrequency="0.005 0.003" numOctaves="1" seed="',
                tokenId.toString(),
                '" stitchTiles="stitch" x="0%" y="0%" width="100%" height="100%" result="turbulence"></feTurbulence><feGaussianBlur stdDeviation="40 0" x="0%" y="0%" width="100%" height="100%" in="turbulence" edgeMode="duplicate" result="blur"></feGaussianBlur><feBlend mode="color-dodge" x="0%" y="0%" width="100%" height="100%" in="SourceGraphic" in2="blur" result="blend"></feBlend></filter>'
            )
        );
    }
}
