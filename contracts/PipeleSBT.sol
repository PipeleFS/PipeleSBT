// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PipeleSBT is ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct TokenInfo {
        address owner;
        string fileId;
    }

    mapping(uint256 => TokenInfo) public idtoinfo;

    event Attest(
        address to,
        uint256 tokenId,
        uint256 ownershipType,
        string fileId
    );
    event Revoke(address to, uint256 tokenId);

    constructor(string memory pipeleUri) ERC1155(pipeleUri) {
        _tokenIdCounter.increment();
    }

    function mint(string memory fileId) public {
        uint256 id = _tokenIdCounter.current();
        _mint(msg.sender, id, 1, "");
        idtoinfo[id].owner = msg.sender;
        idtoinfo[id].fileId = fileId;
        _tokenIdCounter.increment();

        emit Attest(msg.sender, id, 1, fileId);
    }

    function share(address account, uint256 id) public {
        require(
            idtoinfo[id].owner == msg.sender,
            "You are not the owner of this token"
        );
        _mint(account, id, 1, "");
        emit Attest(account, id, 0, "");
    }

    function revoke(address account, uint256 id) public {
        require(
            idtoinfo[id].owner == msg.sender,
            "You are not the owner of this token"
        );
        _burn(account, id, 1);
        emit Revoke(account, id);
    }

    function burn(uint256 id) public {
        _burn(msg.sender, id, 1);
        if (idtoinfo[id].owner == msg.sender) {
            delete idtoinfo[id];
        }
        emit Revoke(msg.sender, id);
    }

    function tokensIssued() public view returns (uint256) {
        return _tokenIdCounter.current() - 1;
    }

    function getIdofFileId(string memory fileId) public view returns (uint256) {
        for (uint256 i = 1; i < _tokenIdCounter.current(); i++) {
            if (
                keccak256(abi.encodePacked((idtoinfo[i].fileId))) ==
                keccak256(abi.encodePacked((fileId)))
            ) {
                return i;
            }
        }
        return 0;
    }

    function _beforeTokenTransfer(
        address,
        address from,
        address to,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) internal pure override {
        require(
            from == address(0) || to == address(0),
            "Not allowed to transfer token"
        );
    }
}
