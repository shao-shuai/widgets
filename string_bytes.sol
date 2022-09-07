pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Dev imports
import "hardhat/console.sol";

contract String {
    // test string and bytes

    string public _string = "US";
    bytes2 public _stringInBytes;
    bytes2 public _bytes = "US";
    string public _bytesInString;
    bytes1 public _firstByte;
    bytes1 public _secondByte;

    function setString(string memory newString) public {
        _string = newString;
    }

    function setBytes(bytes2 newBytes) public {
        _bytes = newBytes;
    }

    function bytesToString() public {
        _bytesInString = string(abi.encodePacked(_bytes));
    }

    function stringToBytes() public {
        _stringInBytes = bytes2(bytes(_string));
    }

    function splitBytes() public {
        _firstByte = _stringInBytes[0];
        _secondByte = _stringInBytes[1];
    }
}
