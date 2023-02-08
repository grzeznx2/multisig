import { ethers } from "hardhat";

describe("MultiSigWallet", function () {
  async function deployOneYearLockFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const MultiSigWallet = await ethers.getContractFactory("MultiSigWallet");
    const multiSigWallet = await MultiSigWallet.deploy();

    return { multiSigWallet, owner, otherAccount };
  }

  describe("Deployment", function () {
  });
});
