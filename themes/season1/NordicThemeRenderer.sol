// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IThemeRenderer} from "../IThemeRenderer.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";
import {LibString} from "solady/src/utils/LibString.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Nordic Theme
/// @notice Colors, font and names for Nordic themed Speedtracer tracks
contract NordicThemeRenderer is IThemeRenderer {
    using Strings for uint256;

    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    uint24 public constant BACKGROUND_COLOR = 0xe9faff;
    uint24 public constant KERB_COLOR = 0x6e8291;
    uint24 public constant ROAD_COLOR = 0xacdbdf;
    uint24 public constant MIDLINE_COLOR = 0xc8e8ed;

    // Staatliches
    string public constant FONT =
        "url(data:font/woff2;base64,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) format('woff2')";

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

    function themeName() external pure returns (string memory) {
        return "Nordic";
    }

    function name(uint256 tokenId)
        external
        view
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

    function background() external pure returns (string memory) {
        return
        "<rect id='bg' width='1200' height='1950' style='stroke:#F9D276; stroke-width:36;' fill='url(#bg-g)' filter='url(#bg-f)' />";
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

    function toHexString(uint256 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(6);
        for (uint256 i = 0; i < 6; ++i) {
            buffer[5 - i] = SYMBOLS[value & 0xF];
            value >>= 4;
        }
        return string(buffer);
    }

    function font() external pure returns (string memory) {
        return FONT;
    }

    function filter(uint256 tokenId) external pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<filter id="noise" filterUnits="userSpaceOnUse"><feTurbulence type="fractalNoise" baseFrequency="0.25" numOctaves="20" result="noise"/><feComposite in="SourceGraphic" in2="noise" operator="in"/></filter><filter id="tf" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="2 2" result="shadow"/><feOffset dx="4" dy="4"/></filter><linearGradient gradientTransform="rotate(30, 0.5, 0.5)" x1="0%" y1="0%" x2="100%" y2="100%" id="bg-g"><stop stop-color="#9dcfde" stop-opacity="1" offset="0%"></stop><stop stop-color="#e9faff" stop-opacity="1" offset="100%"></stop></linearGradient><filter id="bg-f" x="-20%" y="-20%" width="140%" height="140%" filterUnits="objectBoundingBox" primitiveUnits="userSpaceOnUse" color-interpolation-filters="sRGB"><feTurbulence type="fractalNoise" baseFrequency="0.005 0.003" numOctaves="1" seed="',
                tokenId.toString(),
                '" stitchTiles="stitch" x="0%" y="0%" width="100%" height="100%" result="turbulence"></feTurbulence><feGaussianBlur stdDeviation="40 0" x="0%" y="0%" width="100%" height="100%" in="turbulence" edgeMode="duplicate" result="blur"></feGaussianBlur><feBlend mode="color-dodge" x="0%" y="0%" width="100%" height="100%" in="SourceGraphic" in2="blur" result="blend"></feBlend></filter>'
            )
        );
    }
}
