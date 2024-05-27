// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {IPairHooks} from "sudoswap/hooks/IPairHooks.sol";
import {LSSVMPair} from "sudoswap/LSSVMPair.sol";

import {IERC721} from "openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

interface TrackRenderer {
    function currentId() external view returns (uint256);
}

contract FutureTracksValidator is IPairHooks, Ownable {
    address public constant TRACK_RENDERER =
        0x6A89b05f2c0Ce1332d3B013CB69634D55033aC0f;

    error FutureTracksHook__TrackInvalid();

    constructor() {
        _initializeOwner(msg.sender);
    }

    function afterSwapNFTInPair(
        uint256,
        uint256,
        uint256,
        uint256[] calldata _nftsIn
    ) external {
        uint256 currentId = TrackRenderer(TRACK_RENDERER).currentId();
        for (uint256 i = 0; i < _nftsIn.length; i++) {
            if (_nftsIn[i] < currentId + 5) {
                revert FutureTracksHook__TrackInvalid();
            }
        }
    }

    // Stub implementations after here
    function afterNewPair() external {}
    function afterDeltaUpdate(uint128 _oldDelta, uint128 _newDelta) external {}
    function afterSpotPriceUpdate(uint128 _oldSpotPrice, uint128 _newSpotPrice)
        external
    {}
    function afterFeeUpdate(uint96 _oldFee, uint96 _newFee) external {}
    function afterNFTWithdrawal(uint256[] calldata _nftsOut) external {}
    function afterSwapNFTOutPair(
        uint256,
        uint256,
        uint256,
        uint256[] calldata _nftsOut
    ) external {}
    function afterTokenWithdrawal(uint256 _tokensOut) external {}
    function syncForPair(
        address pairAddress,
        uint256 _tokensIn,
        uint256[] calldata _nftsIn
    ) external {}
}
