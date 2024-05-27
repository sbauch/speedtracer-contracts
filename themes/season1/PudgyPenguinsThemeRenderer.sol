// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IThemeRenderer} from "../IThemeRenderer.sol";

/// @author sammybauch.eth
/// @title  Speedtracer PartyDAO Rooms Theme
/// @notice Colors, font and names for PartyDAO Rooms themed Speedtracer tracks
contract PudgyPenguinsThemeRenderer is IThemeRenderer {
    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    uint24 public constant BACKGROUND_COLOR = 0x477DFD;
    uint24 public constant KERB_COLOR = 0x00142D;
    uint24 public constant ROAD_COLOR = 0x80ABFF;
    uint24 public constant MIDLINE_COLOR = 0xF5FDFF;

    string public constant FONT =
        "url(data:font/otf;utf-8;base64,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AHQAcgBhAEIAbwBsAGQAAAAAAAIAAAADAAAAFAADAAEAAAAUAAQAYAAAABQAEAADAAQAIABBAEMAYwBlAGkAbAByAHT//wAAACAAQQBDAGMAZQBpAGwAcgB0////4f/B/8D/of+g/53/m/+W/5UAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAD/tQAyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAoAQgBcAANERkxUABRjeXJsACBsYXRuACwABAAAAAD//wABAAAABAAAAAD//wABAAEABAAAAAD//wABAAIAA2tlcm4AFGtlcm4AFGtlcm4AFAAAAAEAAAABAAQAAgAAAAEACAACADQABAAAADwARAACAAkAAP/xAAAAAAAAAAAAAAAAAAAAAAAA//b/9gAAAAAAAAAAAAAAAQACAAIACAABAAgAAQABAAEAAgAIAAUABAACAAMABwAIAAYAAQAAAAEAAAAKAEgAkgADREZMVAAUY3lybAAibGF0bgAwAAQAAAAA//8AAgAAAAMABAAAAAD//wACAAEABAAEAAAAAP//AAIAAgAFAAZkbm9tACZkbm9tACxkbm9tADJudW1yADhudW1yAD5udW1yAEQAAAABAAMAAAABAAQAAAABAAUAAAABAAAAAAABAAEAAAABAAIABgAOAA4ADgAcABwAHAABAAAAAQAIAAEAFAAJAAEAAAABAAgAAQAGAAwAAQADAAEAAgADAAA=);";

    function themeName() external pure returns (string memory) {
        return "Pudgy Penguins";
    }

    function name(uint256) external pure returns (string memory) {
        return "Arctic Circle";
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
        return
        '<filter id="noise"><feComponentTransfer><feFuncR type="identity" /><feFuncG type="identity" /><feFuncB type="identity" /><feFuncA type="identity" /></feComponentTransfer></filter><filter id="tf" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="2 2" result="shadow"/><feOffset dx="2" dy="2"/></filter>';
    }
}
