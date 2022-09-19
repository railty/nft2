const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Lock2", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixture() {
    const [owner, alice, bob] = await ethers.getSigners();

    const Lock2 = await ethers.getContractFactory("Lock2");
    const lock2 = await Lock2.deploy();

    return { lock2, owner, alice, bob };
  }

  describe("Deployment", function () {
    it("Should set the right host", async function () {
      const { lock2, owner, alice, bob} = await loadFixture(deployFixture);

      await expect(lock2.setHost('a')).to.be.revertedWith("host length greater than 1");
      await expect(lock2.setHost('abc')).not.to.be.reverted;
      expect(await lock2.host()).to.equal('abc');

      await expect(lock2.connect(alice).setHost('xyz')).not.to.be.reverted;
      expect(await lock2.host()).to.equal('xyz');
      expect(await lock2.owner()).to.equal(alice.address);
    });
  });
});
