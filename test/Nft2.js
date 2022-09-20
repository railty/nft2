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

    const Nft2 = await ethers.getContractFactory("Nft2");
    //const nft2 = await Nft2.deploy(RATE, "https://localhost:3000/{id}.json");
    const nft2 = await Nft2.deploy(RATE, "https://localhost:3000/");
    return { nft2, owner, alice, bob };
  }

  describe("Deployment", function () {
    it("Should work", async function () {
      const { nft2, owner, alice, bob} = await loadFixture(deployFixture);

      const days = 100;
      await expect(nft2.connect(alice).mintNFT('abc', days, {
        //from: alice.address,
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;


      const nftId = await nft2.hosts('abc');
      const nftURI = await nft2.uri(nftId);
      console.log(nftURI);

    });
  });
});
