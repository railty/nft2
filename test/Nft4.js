const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const TWEI = 1_000_000_000_000;
const RATE = 100*TWEI;

describe("Nft4", function () {
  async function deployFixture() {
    const [owner, alice, bob] = await ethers.getSigners();

    const Nft4 = await ethers.getContractFactory("NFT4");
    const nft4 = await Nft4.deploy(RATE, "https://localhost:3000/");
    return { nft4, owner, alice, bob };
  }

  describe("Deployment", function () {
    it("basic work", async function () {
      const { nft4, owner, alice, bob} = await loadFixture(deployFixture);

      const days = 123;
      await expect(await nft4.connect(alice).register("alice-1", days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;
      expect(await nft4.ownerOf(await nft4.token("alice-1"))).to.be.equal(alice.address);

      await expect(await nft4.connect(alice).register("alice-2", days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;
      await expect(await nft4.connect(alice).register("alice-3", days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;

      await expect(await nft4.connect(bob).register("bob-1", days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;
      expect(await nft4.ownerOf(await nft4.token("bob-1"))).to.be.equal(bob.address);

      await expect(await nft4.connect(bob).register("bob-2", days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;
      await expect(await nft4.connect(bob).register("bob-3", days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;

      const lastTokenId = await nft4.lastTokenId();
      console.log("lastTokenId = ", lastTokenId);

      for (let i=1; i<=lastTokenId; i++){
        const data = await nft4.data(i);
        expect(data.expiredAt).to.be.equal(Math.floor(Date.now()/1000/60/60/24+days));
      }

      //bob cannot register same host
      await expect(nft4.connect(bob).register('alice-1', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).to.be.revertedWith("You aren't the owner and record is not expired yet");

      //days-10 days later, 10 days left to expire
      const unlockTime1 = (await time.latest()) + (days-10)*60*60*24;
      await time.increaseTo(unlockTime1);

      //bob still cannot register
      await expect(nft4.connect(bob).register('alice-1', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).to.be.revertedWith("You aren't the owner and record is not expired yet");

      //alice can register/renew
      const token1 = await nft4.token('alice-1');

      const tm1 = (await nft4.data(token1)).expiredAt;

      await expect(nft4.connect(alice).register('alice-1', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;
      const token2 = await nft4.token('alice-1');
      //same token
      expect(token1).to.be.equal(token2);
      const tm2 = (await nft4.data(token1)).expiredAt;
      expect(tm2-tm1).to.equal(days);

      //another days+20 days later, or 20 days after expired
      const unlockTime2 = (await time.latest()) + (days+20)*60*60*24;
      await time.increaseTo(unlockTime2);

      //bob can now register as it is expired
      const token11 = await nft4.token('alice-1');
      const tm11 = (await nft4.data(token11)).expiredAt;
      
      await expect(nft4.connect(bob).register('alice-1', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;

      const token12 = await nft4.token('alice-1');
      //same token
      expect(token11).to.be.equal(token12);

      const tm12 = (await nft4.data(token11)).expiredAt;
      expect(tm12-tm11).to.equal(days+10);

      //another days-10 later
      const unlockTime3 = (await time.latest()) + (days-10)*60*60*24;
      await time.increaseTo(unlockTime3);

      //alice cannot renew it as it belongs to bob now
      await expect(nft4.connect(alice).register('alice-1', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).to.be.revertedWith("You aren't the owner and record is not expired yet");

      const token3 = await nft4.token('alice-1');
      //transfer the nft to alice

      for (let i=1; i<=lastTokenId; i++){
        try{
          const owner = await nft4.ownerOf(i);
          const host = (await nft4.data(i)).host;
          console.log(i, owner, host);
        }
        catch(e){
          console.log(i, e.reason);
        }
      }

      nft4.on("Transfer", (_from,_to,_value) => {
        console.log("xxxxxxxxxxxxxxxxx", _from,_to,_value);
      });

      const tx = await nft4.connect(bob).transferFrom(bob.address, alice.address, token3);
      await expect(tx).to.emit(nft4, "Transfer").withArgs(bob.address, alice.address, token3);

      console.log("--------------------");
      for (let i=1; i<=lastTokenId; i++){
        try{
          const owner = await nft4.ownerOf(i);
          const host = (await nft4.data(i)).host;
          console.log(i, owner, host);
        }
        catch(e){
          console.log(i, e.reason);
        }
      }

      //alice can renew it again
      await expect(nft4.connect(alice).register('alice-1', days, {
        value: ethers.BigNumber.from(RATE).mul(days)
      })).not.to.be.reverted;

      const nAlice = await nft4.balanceOf(alice.address);
      const nBob = await nft4.balanceOf(bob.address);

      console.log(nAlice, nBob);

      const tokensA = await nft4.tokens(alice.address);
      console.log("Alice token = ", tokensA);

      const tokensB = await nft4.tokens(bob.address);
      console.log("Bob token = ", tokensB);

      await new Promise((resolve)=>{
        setTimeout(()=>{
          console.log("aaaaaa");
          resolve();
        }, 15000);
      });
    });



    /*
    it("Should work", async function () {






    });
*/
  });
});
