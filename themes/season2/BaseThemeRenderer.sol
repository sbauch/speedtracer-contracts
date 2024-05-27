// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {SpeedtracerTheme} from "./SpeedtracerTheme.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Base Theme
/// @notice Colors, font and names for base themed Speedtracer tracks
contract BaseThemeRenderer is
    SpeedtracerTheme(0x23c552, 0x105b25, 0xc9c9c9, 0xf2f2f2)
{
    using Strings for uint256;

    constructor(address font) {
        setFontAddress(font);
    }

    string[] private prefixes = [
        "New",
        "",
        "Old",
        "",
        "Open",
        "Grand",
        "",
        "International",
        "Global",
        "",
        "Classic",
        "",
        "National",
        "",
        "1969",
        "Cannonball",
        "Royal",
        "Vintage",
        "",
        "Historic",
        "",
        "Continental",
        "",
        "Legacy"
    ];

    // Solidity array containing some of the most populous cities in the United States where English is the main language
    string[] private cities = [
        "New York",
        "American",
        "French",
        "German",
        "Spanish",
        "Madrid",
        "Barcelona",
        "Paris",
        "Munich",
        "Berlin",
        "Reno",
        "Indy",
        "New York City",
        "Los Angeles",
        "Chicago",
        "Miami",
        "Dallas",
        "Philadelphia",
        "Houston",
        "Washington, D.C.",
        "Atlanta",
        "Boston",
        "Phoenix",
        "San Francisco",
        "Seattle",
        "San Diego",
        "Minneapolis",
        "Tampa",
        "Denver",
        "Brooklyn",
        "Queens",
        "Riverside",
        "Baltimore",
        "Las Vegas",
        "Portland",
        "San Antonio",
        "St. Louis",
        "Sacramento",
        "Orlando",
        "San Jose",
        "Cleveland",
        "Pittsburgh",
        "Austin",
        "Cincinnati",
        "Kansas City",
        "Indianapolis",
        "Columbus",
        "Charlotte",
        "Virginia Beach",
        "Bronx",
        "Milwaukee",
        "Providence",
        "Jacksonville",
        "Salt Lake City",
        "Nashville",
        "Detroit",
        "Memphis",
        "Louisville",
        "Richmond",
        "Oklahoma City",
        "Hartford",
        "New Orleans",
        "Buffalo",
        "Raleigh",
        "Birmingham",
        "Fort Worth",
        "Rochester",
        "Omaha",
        "Fresno",
        "Long Beach",
        "Tulsa",
        "Honolulu",
        "Albuquerque",
        "Worcester",
        "Fresno",
        "Manchester",
        "London",
        "Birmingham",
        "Newcastle",
        "Sheffield",
        "Liverpool",
        "Leeds",
        "Bristol",
        "Edinburgh",
        "Rome",
        "Vienna",
        "Amsterdam",
        "Brussels",
        "Sydney",
        "Houston",
        "San Antonio",
        "Dallas",
        "Milan",
        "Dublin",
        "Zurich",
        "Melbourne"
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

    function themeName() external pure override returns (string memory) {
        return "Basic";
    }

    function name(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        uint256 prefixIndex = tokenId % prefixes.length;
        uint256 cityIndex = (tokenId + prefixIndex) % cities.length;
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

    function background() external view override returns (string memory) {
        return
        '<rect width="1200" height="1950" style="stroke:#c9c9c9; stroke-width:48;" fill="#23c552" filter="url(#grass)" />';
    }

    function filter(uint256 id)
        external
        view
        override
        returns (string memory)
    {
        return string(
            abi.encodePacked(
                '<filter id="noise" filterUnits="userSpaceOnUse"><feTurbulence type="fractalNoise" baseFrequency="0.25" numOctaves="20" result="noise"/><feComposite in="SourceGraphic" in2="noise" operator="in"/></filter><filter id="tf" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="2 2" result="shadow"/><feOffset dx="2" dy="2"/></filter><radialGradient id="bg-g"><stop offset="0%" stop-color="#20b44b"></stop><stop offset="100%" stop-color="#23c552"></stop></radialGradient><filter id="bg-f" x="-20%" y="-20%" width="140%" height="140%" filterUnits="objectBoundingBox" primitiveUnits="userSpaceOnUse" color-interpolation-filters="sRGB"><feTurbulence type="fractalNoise" baseFrequency="100" numOctaves="1" seed="',
                id.toString(),
                '" stitchTiles="stitch" x="0%" y="0%" width="100%" height="100%" result="turbulence"></feTurbulence><feGaussianBlur stdDeviation="5 39" x="0%" y="0%" width="100%" height="100%" in="turbulence" edgeMode="duplicate" result="blur"></feGaussianBlur><feBlend mode="color-burn" x="0%" y="0%" width="100%" height="100%" in="SourceGraphic" in2="blur" result="blend"></feBlend></filter> <filter id="inner-stroke" x="-50%" y="-50%" width="200%" height="200%"><feMorphology operator="dilate" radius="5" in="SourceAlpha" result="expanded"/><feFlood flood-color="black" result="color"/><feComposite in="color" in2="expanded" operator="in" result="inner-stroke"/><feComposite in="inner-stroke" in2="SourceAlpha" operator="in"/></filter><filter id="grass" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="2" result="noise" /><feDiffuseLighting in="noise" lighting-color="white" surfaceScale="1" result="diffuseLighting"><feDistantLight azimuth="45" elevation="55" /></feDiffuseLighting><feBlend in="SourceGraphic" in2="diffuseLighting" mode="multiply" /></filter>'
            )
        );
    }
}
