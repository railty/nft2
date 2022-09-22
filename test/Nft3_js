const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const TWEI = 1_000_000_000_000;
const RATE = 100*TWEI;

describe("Nft3", function () {
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

      //cannot register 1 letter
      await expect(nft3.connect(bob).mintNFT('a', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).to.be.revertedWith("host length must be greater than 1");

      //alice can register
      await expect(nft3.connect(alice).mintNFT('alice-host', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;
      expect((await nft3.ownerOf(1))).to.equal(alice.address);
      await expect(nft3.ownerOf(2)).to.be.revertedWith("ERC721: invalid token ID");

      //bob cannot register same host
      await expect(nft3.connect(bob).mintNFT('alice-host', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).to.be.revertedWith("You aren't the owner and record is not expired yet");

      //bob can register diffrent host
      await expect(nft3.connect(bob).mintNFT('bob-host', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;

      //100-10 = 90 days later
      const unlockTime1 = (await time.latest()) + (days-10)*60*60*24;
      await time.increaseTo(unlockTime1);

      //bob still cannot register
      await expect(nft3.connect(bob).mintNFT('alice-host', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).to.be.revertedWith("You aren't the owner and record is not expired yet");

      //alice can register/renew
      const tm1 = (await nft3.hosts('alice-host')).expiredAt;
      await expect(nft3.connect(alice).mintNFT('alice-host', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;
      const tm2 = (await nft3.hosts('alice-host')).expiredAt;
      expect((tm2-tm1)/60/60/24).to.equal(days);

      //100-10+20 = 110 days later
      const unlockTime2 = (await time.latest()) + (days+20)*60*60*24;
      await time.increaseTo(unlockTime2);

      //bob can now register as it is expired
      const rec1 = await nft3.hosts('alice-host');
      await expect(nft3.connect(bob).mintNFT('alice-host', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;
      const rec2 = await nft3.hosts('alice-host');
      expect(rec1.tokenId).not.to.equal(rec2.tokenId);

      const tm = rec2.expiredAt - rec1.expiredAt;
      expect(Math.floor(tm/60/60/24)).to.equal(days+10);

      const lastId = await nft3.lastId();
      console.log(lastId);
      for (let i=0; i<=lastId; i++){
        try{
          const owner = await nft3.ownerOf(i);
          const host = await nft3.ids(i);
          console.log(i, owner, host);
        }
        catch(e){
          console.log(i, e.reason);
        }
      }
      console.log("-------------------");


      //alice cannot renew it as it belongs to bob now
      await expect(nft3.connect(alice).mintNFT('alice-host', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).to.be.revertedWith("You aren't the owner and record is not expired yet");

      //transfer the nft to alice
      await nft3.connect(bob).transferFrom(bob.address, alice.address, 4);

      for (let i=0; i<=lastId; i++){
        try{
          const owner = await nft3.ownerOf(i);
          const host = await nft3.ids(i);
          console.log(i, owner, host);
        }
        catch(e){
          console.log(i, e.reason);
        }
      }

      //alice can renew it again
      await expect(nft3.connect(alice).mintNFT('alice-host', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;

      const nAlice = await nft3.balanceOf(alice.address);
      const nBob = await nft3.balanceOf(bob.address);

      console.log(nAlice, nBob);

      for (let i=0; i<nAlice; i++){
        const tokenId = await nft3.tokenOfOwnerByIndex(alice.address, i);
        console.log("Alice token = ", tokenId);
      }

      for (let i=0; i<nBob; i++){
        const tokenId = await nft3.tokenOfOwnerByIndex(bob.address, i);
        console.log("Bob token = ", tokenId);
      }
    });

    it("sign message should work", async function () {
      const { nft3, owner, alice, bob} = await loadFixture(deployFixture);

      const nonce = await nft3.nonce()
      console.log("nonce:", nonce);
      const msg1 = ethers.utils.keccak256(
        //ethers.utils.defaultAbiCoder.encode(['uint256', 'address', 'uint256',  'string'], [nonce, alice.address, 1234, "hello world"])
        ethers.utils.defaultAbiCoder.encode(['address', 'uint256',  'string'], [alice.address, 1234, "hello world"])
      );
      const msg2 = ethers.utils.arrayify(msg1);

      const signature = await alice.signMessage(msg2);

      await time.increase(2000);
      
      const address = await nft3.connect(alice).verifySignature(signature);
      expect(address).to.be.equal(alice.address);

      //verify from js side
      const address2 = await ethers.utils.verifyMessage(msg2, signature);
      expect(address2).to.be.equal(alice.address);

    });
  });
});
