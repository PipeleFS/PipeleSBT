// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PipeleSBT is ERC1155, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    event Attest(address to, uint256 tokenId);
    event Revoke(address to, uint256 tokenId);

    constructor() ERC1155("") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(
        address account,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        uint256 id = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(account, id, amount, data);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        require(
            from == address(0) || to == address(0),
            "Not allowed to transfer token"
        );
    }

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        if (from != address(0)) {
            emit Attest(to, ids[0]);
        } else if (to != address(0)) {
            emit Revoke(to, ids[0]);
        }
    }

    function revoke(
        address user,
        uint256 id,
        uint256 value
    ) public onlyOwner {
        _burn(user, id, value);
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );

        _burn(account, id, value);
    }
}
