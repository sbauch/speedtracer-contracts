// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface IRaceResults {
    function withdrawTrack(uint256 trackId) external;
}

contract DisburseSeason {
    function disburse(address raceResults, uint256 fromId, uint256 toId)
        public
    {
        IRaceResults raceResultsContract = IRaceResults(raceResults);

        for (uint256 i = fromId; i <= toId; i++) {
            raceResultsContract.withdrawTrack(i);
        }
    }
}
