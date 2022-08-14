//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

// IMPORTS CONTRACTS

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// IMPORT INTERFACES

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// IMPORTS LIBRARIES

import "base64-sol/base64.sol";

// CONTRACT

contract DynamicSvgNft is ERC721 {
    // STATE VARIABLES

    uint256 private s_tokenCounter;
    string private i_lowImageURI;
    string private i_highImageUri;
    string private constant base64EncodedSvgPrefix = "data:image/svg+xml;base64,";

    AggregatorV3Interface internal immutable i_priceFeed;

    // MAPPINGS

    mapping(uint256 => int256) private s_tokenIdToHighValue;

    // EVENTS

    event NftMint(uint256 indexed tokenId, int256 highValue);

    // CONSTRUCTOR

    constructor(
        string memory lowSvg,
        string memory highSvg,
        address priceFeedAddress
    ) ERC721("Dynamic SVG NFT", "DSN") {
        s_tokenCounter = 0;
        i_lowImageURI = svgToImage(lowSvg);
        i_highImageUri = svgToImage(highSvg);
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // FUNCTIONS

    function mintNft(int256 highValue) public {
        s_tokenIdToHighValue[s_tokenCounter] = highValue;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
        emit NftMint(s_tokenCounter, highValue);
    }

    // PURE / VIEW FUNCTIONS

    function svgToImage(string memory svg) public pure returns (string memory) {
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(base64EncodedSvgPrefix, svgBase64Encoded));
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        string memory imageURI = i_lowImageURI;
        if (price >= s_tokenIdToHighValue[tokenId]) {
            imageURI = i_highImageUri;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '", "description":"An NFT that changes based on the Chainlink Feed", ',
                                '"attributes":[{"trait_type": "coolness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getLowSVG() public view returns (string memory) {
        return i_lowImageURI;
    }

    function getHighSVG() public view returns (string memory) {
        return i_highImageUri;
    }
}
