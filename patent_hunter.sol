// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Dev imports
import "hardhat/console.sol";

error SimpleStorage_NotOpened();
error SimpleStorage_PatentHuntedAlready(uint256 patentNumber);
error SimpleStorage_InvalidPatentNumber();
error SimpleStorage_MemoMissing();

contract SimpleStorage is ERC721, ERC721URIStorage, Ownable {
    event NftMinted(uint256 patentNumber, address minter);

    struct Patent {
        uint256 patentNumber;
        string memo;
        address hunter;
    }

    address public royaltyToken;
    Patent[] public patents;
    mapping(address => uint256) public hunterToPatents;
    mapping(uint256 => uint256) public patentToToken;
    mapping(uint256 => Patent) public tokenToPatent;
    bool private _status;
    uint256 public publicationNumberHead;
    uint256 public publicationNumberTail;

    using Counters for Counters.Counter;
    Counters.Counter public _tokenIdCounter;
    string public baseUrl = "https://patents.google.com/patent/US";

    constructor(
        bool status,
        uint256 head,
        uint256 tail,
        address _royaltyToken
    ) ERC721("Patent Hunter", "PATH") {
        _status = status;
        publicationNumberHead = head;
        publicationNumberTail = tail;
        royaltyToken = _royaltyToken;
        transferOwnership(0x22391eAb56E4dbBcb7bfa7f3Ac7af63b1838d3CA);
    }

    function safeMint(uint256 patentNumber, string memory memo) public {
        if (patentToToken[patentNumber] != 0) {
            revert SimpleStorage_PatentHuntedAlready(patentNumber);
        }
        if (_status == false) {
            revert SimpleStorage_NotOpened();
        }

        if (
            patentNumber < publicationNumberHead ||
            patentNumber > publicationNumberTail
        ) {
            revert SimpleStorage_InvalidPatentNumber();
        }

        if (
            keccak256(abi.encodePacked(memo)) == keccak256(abi.encodePacked(""))
        ) {
            revert SimpleStorage_MemoMissing();
        }
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        patents.push(Patent(patentNumber, memo, msg.sender));
        tokenToPatent[tokenId] = Patent(patentNumber, memo, msg.sender);
        hunterToPatents[msg.sender] += 1;
        patentToToken[patentNumber] = tokenId;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(
            tokenId,
            string.concat(baseUrl, Strings.toString(patentNumber))
        );
        emit NftMinted(patentNumber, msg.sender);
    }

    // fall back function
    receive() external payable {}

    // withdraw function for withdrawing funds
    function withdraw() public onlyOwner {
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    // function to retrieve the total number of tokens
    function totalPatentsHunted()
        public
        view
        returns (Counters.Counter memory)
    {
        return _tokenIdCounter;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function setStatus(bool status) public onlyOwner {
        _status = status;
    }

    function setPublicationNumber(uint256 head, uint256 tail) public onlyOwner {
        publicationNumberHead = head;
        publicationNumberTail = tail;
    }

    function getTokenFromPatent(uint256 patentNumber)
        public
        view
        returns (uint256)
    {
        return patentToToken[patentNumber];
    }

    function setRoyaltyToken(address _royaltyToken) public onlyOwner {
        royaltyToken = _royaltyToken;
    }

    function payRoyaltyFee(
        address from,
        address to,
        uint256 amount
    ) public {
        IERC20 token = IERC20(royaltyToken);
        token.transferFrom(from, to, amount);
    }
}
