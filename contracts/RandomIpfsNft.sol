// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

// IMPORTS

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// ERRORS

error RandomIpfsNft__OutOfBounds();

// CONTRACT

contract RandomIpfsNft is VRFConsumerBaseV2, ERC721 {
    // TYPE DECLARATIONS
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }
    // CHAINLINK VRF VARIABLES

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // NFT VARIABLES
    uint256 private s_tokenCounter;
    uint256 internal constant MAX_CHANCE = 100;

    // MAPPINGS

    mapping(uint256 => address) public s_requestIdToSender;

    // EVENTS

    event NFTMinted(Breed breed, address minter);

    // CONSTRUCTOR

    constructor(
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Random IPFS NFT", "RIN") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane; // KeyHash
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    // FUNCTIONS

    function requestNft() public returns (uint256 requestId) {
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address dogOwner = s_requestIdToSender[requestId];
        uint256 newItemId = s_tokenCounter;
        s_tokenCounter++;
        uint256 modded = randomWords[0] % MAX_CHANCE;
        Breed dogBreed = getBreedFromModded(modded);
        _safeMint(dogOwner, newItemId);
        emit NFTMinted(dogBreed, dogOwner);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {}

    // PURE - VIEW FUNCTIONS

    function getBreedFromModded(uint256 modded) public pure returns (Breed) {
        uint256 cumulative = 0;
        uint256[3] memory chanceArray = getChanceArray();
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (modded >= cumulative && modded < cumulative + chanceArray[i]) {
                return Breed(i);
            }
            cumulative += chanceArray[i];
        }
        revert RandomIpfsNft__OutOfBounds();
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        return [10, 30, MAX_CHANCE];
    }
}
