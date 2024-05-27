// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IFont} from "./fonts/IFont.sol";

contract SpeedtracerTheme {
    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    uint24 public BACKGROUND_COLOR = 0xFFE901;
    uint24 public KERB_COLOR = 0xAF0C1A;
    uint24 public ROAD_COLOR = 0xFFAC01;
    uint24 public MIDLINE_COLOR = 0xFFE901;
    IFont public FONT;

    constructor(
        uint24 _background,
        uint24 _kerb,
        uint24 _road,
        uint24 _midline
    ) {
        BACKGROUND_COLOR = _background;
        KERB_COLOR = _kerb;
        ROAD_COLOR = _road;
        MIDLINE_COLOR = _midline;
    }

    function setFontAddress(address _font) internal {
        FONT = IFont(_font);
    }

    function background() external view virtual returns (string memory) {
        return string(
            abi.encodePacked(
                "<rect id='bg' width='100%' height='100%' fill='#",
                toHexString(BACKGROUND_COLOR),
                "' />"
            )
        );
    }

    function filter(uint256) external view virtual returns (string memory) {
        return
        '<filter id="noise"><feComponentTransfer><feFuncR type="identity" /><feFuncG type="identity" /><feFuncB type="identity" /><feFuncA type="identity" /></feComponentTransfer></filter>';
    }

    function name(uint256 tokenId)
        external
        view
        virtual
        returns (string memory)
    {
        return string(abi.encodePacked("Speedtracer #", tokenId));
    }

    function themeName() external view virtual returns (string memory) {
        return "Speedtracer";
    }

    function road() external view virtual returns (string memory) {
        return toHexString(ROAD_COLOR);
    }

    function kerb() external view virtual returns (string memory) {
        return toHexString(KERB_COLOR);
    }

    function midline() external view virtual returns (string memory) {
        return toHexString(MIDLINE_COLOR);
    }

    function themeColors() public view returns (uint96) {
        return (uint96(BACKGROUND_COLOR) << 72) | (uint96(KERB_COLOR) << 48)
            | (uint96(ROAD_COLOR) << 24) | uint96(MIDLINE_COLOR);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(6);
        for (uint256 i = 0; i < 6; ++i) {
            buffer[5 - i] = SYMBOLS[value & 0xF];
            value >>= 4;
        }
        return string(buffer);
    }

    function font() external view returns (string memory) {
        return FONT.font();
    }
}
