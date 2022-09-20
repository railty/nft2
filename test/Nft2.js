const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const TWEI = 1_000_000_000_000;

describe("Nft2", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixture() {
    const [owner, alice, bob] = await ethers.getSigners();

    const Nft2 = await ethers.getContractFactory("Nft2");
    const nft2 = await Nft2.deploy();
    return { nft2, owner, alice, bob };
  }

  describe("Deployment", function () {
    it("Should set the right host", async function () {
      const { nft2, owner, alice, bob} = await loadFixture(deployFixture);

    });
  });
});
