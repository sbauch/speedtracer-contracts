// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

/// @author sammybauch.eth
/// @title  Speedtracer Theme Renderer Interface
/// @notice Track renderer calls theme for colors, font and name

interface IFont {
    function font() external pure returns (string memory);
    // function name() external pure returns (string memory);
}
