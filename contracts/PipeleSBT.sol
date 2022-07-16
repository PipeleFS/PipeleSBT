// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PipeleSBT is ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => address) public sbtOwner;
    mapping(uint256 => string) public idToCID;

    event Attest(address to, uint256 tokenId, uint256 ownershipType, string cid);
    event Revoke(address to, uint256 tokenId);

    constructor() ERC1155("") {}

    function mint(string memory cid) public {
        uint256 id = _tokenIdCounter.current();
        _mint(msg.sender, id, 1, "");
        sbtOwner[id] = msg.sender;
        idToCID[id] = cid;
        emit Attest(msg.sender, id, 1, cid);
        _tokenIdCounter.increment();
    }
    
    function share(address account, uint256 id) public {
        require(
            sbtOwner[id] == msg.sender,
            "You are not the owner of this token"
        );
        _mint(account, id, 1, "");
        emit Attest(account, id, 0, idToCID[id]);
    }

    function revoke(address account, uint256 id) public {
        require(
            sbtOwner[id] == msg.sender,
            "You are not the owner of this token"
        );
        _burn(account, id, 1);
        emit Revoke(account, id);
    }

    function burn(uint256 id) public {
        _burn(msg.sender, id, 1);
        if(sbtOwner[id] == msg.sender) {
            delete sbtOwner[id];
        }
        emit Revoke(msg.sender, id);
    }

    function tokensIssued() public view returns (uint256) {
        return _tokenIdCounter.current();
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
