const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const TWEI = 1_000_000_000_000;
const RATE = 100*TWEI;

describe("Nft2", function () {
  async function deployFixture() {
    const [owner, alice, bob] = await ethers.getSigners();

    const Nft3 = await ethers.getContractFactory("Nft3");
    //const nft2 = await Nft2.deploy(RATE, "https://localhost:3000/{id}.json");
    const nft3 = await Nft3.deploy(RATE);
    return { nft3, owner, alice, bob };
  }

  describe("Deployment", function () {
    it("Should work", async function () {
      const { nft3, owner, alice, bob} = await loadFixture(deployFixture);

      const days = 100;
      await expect(nft3.connect(alice).mintNFT('alice-host', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;

      expect((await nft3.ownerOf(1))).to.equal(alice.address);

      await expect(nft3.ownerOf(2)).to.be.revertedWith("ERC721: invalid token ID");
    });
  });
});
