// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

/// @author sammybauch.eth
/// @title  Speedtracer Theme Renderer Interface
/// @notice Track renderer calls theme for colors, font and name

interface IThemeRenderer {
    function themeName() external view returns (string memory);
    function name(uint256 tokenId) external view returns (string memory);
    function background() external view returns (string memory);
    function road() external view returns (string memory);
    function midline() external view returns (string memory);
    function kerb() external view returns (string memory);
    function font() external view returns (string memory);
    function filter(uint256 tokenId) external view returns (string memory);
}
