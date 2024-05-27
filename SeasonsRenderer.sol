// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {IRenderer} from "./IRenderer.sol";
/// @author sammybauch.eth
/// @title  Proxy for token rendering
/// @notice Delegate to the appropriate renderer based on the tokenId
///         to support our approach to Seasons

contract SeasonsRenderer is Ownable {
    struct RendererSeason {
        address renderer;
        uint256 startingTokenId;
    }

    error CannotUpdatePastSeasons();

    string private preRevealUri;
    RendererSeason[] private seasons;

    // ****************** //
    // *** INITIALIZE *** //
    // ****************** //

    constructor(string memory _tokenUri) {
        preRevealUri = _tokenUri;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        address renderer = this.getCurrentRenderer(tokenId);

        if (address(renderer) != address(0)) {
            return IRenderer(renderer).tokenURI(tokenId);
        }
        return preRevealUri;
    }

    function getCurrentRenderer(uint256 tokenId)
        external
        view
        returns (address season)
    {
        for (uint256 i = seasons.length; i > 0; i--) {
            if (tokenId >= seasons[i - 1].startingTokenId) {
                return seasons[i - 1].renderer;
            }
        }
    }

    // ************* //
    // *** ADMIN *** //
    // ************* //

    function addSeason(address _renderer, uint256 _startTokenId)
        external
        onlyOwner
    {
        if (
            seasons.length > 0
                && _startTokenId <= seasons[seasons.length - 1].startingTokenId
        ) {
            revert CannotUpdatePastSeasons();
        }
        seasons.push(
            RendererSeason({renderer: _renderer, startingTokenId: _startTokenId})
        );
    }
}
