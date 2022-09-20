const moment = require("moment");
const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const TWEI = 1_000_000_000_000;
const RATE = 100*TWEI;

describe("Lock2", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixture() {
    const [owner, alice, bob] = await ethers.getSigners();

    const Lock2 = await ethers.getContractFactory("Lock2");
    const lock2 = await Lock2.deploy(RATE);
    return { lock2, owner, alice, bob };
  }

  describe("Deployment", function () {
    it("Should set the right host", async function () {
      const { lock2, owner, alice, bob} = await loadFixture(deployFixture);

      //const now = await time.latest();
      //const expiredAt = moment(now*1000).add(3, 'months').add(1, 'days').startOf('day').unix();
      await expect(lock2.setHost('a', 1)).to.be.revertedWith("host length must be greater than 1");

      const days = 31;

      {
        await expect(lock2.connect(alice).setHost('alice-host', days, {
          //from: alice.address,
          value: days*RATE
        })).not.to.be.reverted;
    
        let {host:_host, owner:_owner} = await lock2.hosts('alice-host');
        expect(_host).to.equal('alice-host');
        expect(_owner).to.equal(alice.address);
      }

      {
        await expect(lock2.connect(bob).setHost('bob-host', days, {
          //from: bob.address,
          value: days*RATE
        })).not.to.be.reverted;
    
        let {host:_host, owner:_owner} = await lock2.hosts('bob-host');
        expect(_host).to.equal('bob-host');
        expect(_owner).to.equal(bob.address);
      }

      {
        await expect(lock2.connect(bob).setHost('alice-host', days, {
          //from: bob.address,
          value: days*RATE
        })).to.be.revertedWith("You aren't the owner and record is not expired yet");
    
        const unlockTime = (await time.latest()) + days*60*60*24;
        await time.increaseTo(unlockTime);

        await expect(lock2.connect(bob).setHost('alice-host', days, {
          //from: bob.address,
          value: days*RATE
        })).not.to.be.reverted;

        let {host:_host, owner:_owner, expiredAt} = await lock2.hosts('alice-host');
        expect(_host).to.equal('alice-host');
        expect(_owner).to.equal(bob.address);

        const numOfDays = Math.floor(moment.duration(moment(expiredAt.toNumber()*1000).diff(moment())).as('days'));
        expect(numOfDays).to.equal(2 * days);

        expect(await ethers.provider.getBalance(lock2.address)).to.equal(ethers.BigNumber.from(RATE).mul(3 * days));
      }
    });
  });
});
