// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ERC721} from "solady/src/tokens/ERC721.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

contract SpeedtracerRaceResult is Ownable, ERC721 {
    using ECDSA for bytes32;

    struct RaceResult {
        uint128 timeInMilliseconds;
        uint32 trackId;
        string metadataUrl;
    }

    uint256 public mintCost = 0.0008 ether;
    address public signer = 0x6460cC895A722692c42454965f5480345Dbd61E4;
    ERC721 public speedtracer;
    uint256 public withdrawable;
    uint256 public purse;

    uint256 public pursePctShare = 50;

    mapping(address => uint256) bannedUntil;
    mapping(uint256 => string) tokenURIs;

    // Events
    event PlayerBanned(address player, uint256 until);
    event ResultRecorded(uint128 time, uint256 track, uint256 tokenId);
    event URI(string, uint256);

    // Errors
    error Banned();
    error InvalidRace();
    error OwnerSendFailed();
    error PrizeSendFailed();
    error WrongPayment();

    constructor(address _speedtracer) ERC721() {
        _initializeOwner(msg.sender);
        speedtracer = ERC721(_speedtracer);
    }

    function mintWithProof(bytes calldata signature, RaceResult calldata result)
        external
        payable
    {
        if (msg.value != mintCost) revert WrongPayment();
        if (bannedUntil[msg.sender] > block.number) revert Banned();
        if (!verifyRaceProof(result, signature)) revert InvalidRace();

        uint256 purseSplit = (mintCost * pursePctShare) / 100;
        uint256 _tokenId = tokenId(msg.sender, result.trackId);
        purse += purseSplit;

        withdrawable += mintCost - purseSplit;

        if (isTokenURIEmpty(_tokenId)) {
            _mint(msg.sender, _tokenId);
        }

        tokenURIs[_tokenId] = result.metadataUrl;
        emit URI(tokenURIs[_tokenId], _tokenId);

        emit ResultRecorded(result.timeInMilliseconds, result.trackId, _tokenId);
    }

    function verifyRaceProof(RaceResult calldata result, bytes memory signature)
        public
        view
        returns (bool)
    {
        bytes32 message = createMessage(result).toEthSignedMessageHash();

        return message.recover(signature) == signer;
    }

    function createMessage(RaceResult calldata result)
        internal
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                signer,
                msg.sender,
                result.trackId,
                result.timeInMilliseconds,
                result.metadataUrl
            )
        );
    }

    function tokenId(address userAddress, uint32 trackId)
        public
        pure
        returns (uint256)
    {
        uint256 packedData = uint256(uint160(userAddress)) << 96;
        packedData |= trackId;
        return packedData;
    }

    function isTokenURIEmpty(uint256 _tokenId) public view returns (bool) {
        bytes memory tokenURIBytes = bytes(tokenURIs[_tokenId]);
        return tokenURIBytes.length == 0;
    }

    function updateSigner(address newSigner) external onlyOwner {
        signer = newSigner;
    }

    function banPlayer(address toBan, uint256 forBlocks) external onlyOwner {
        bannedUntil[toBan] = block.number + forBlocks;
        emit PlayerBanned(toBan, block.number + forBlocks);
    }

    function updateCost(uint256 newCost) external onlyOwner {
        mintCost = newCost;
    }

    /// @dev Callable by anyone. Distributes withdrawable funds to the project creators
    function withdraw() external {
        uint256 toWithdraw = withdrawable;
        withdrawable = 0;

        (bool success,) = owner().call{value: toWithdraw}("");
        if (!success) revert OwnerSendFailed();
    }

    uint256[9] winnerPctShares = [25, 18, 15, 12, 10, 8, 6, 4, 2];

    function disburseWinnings(address[9] calldata winners) external onlyOwner {
        uint256 totalPrize = purse;

        for (uint256 i = 0; i < 9; i++) {
            uint256 prize = (totalPrize * winnerPctShares[i]) / 100;
            (bool success,) = winners[i].call{value: prize}("");
            if (!success) revert PrizeSendFailed();
            purse -= prize;
        }

        if (purse > 0) revert PrizeSendFailed();
    }

    /// ERC-721
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert TokenDoesNotExist();

        return tokenURIs[tokenId];
    }

    function name() public pure override returns (string memory) {
        return "Speedtracer Race Result";
    }

    function symbol() public pure override returns (string memory) {
        return "SPEEDRR";
    }

    receive() external payable {
        purse += msg.value;
    }
}
