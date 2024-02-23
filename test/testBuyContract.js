const { expect } = require("chai");
const { ethers, network } = require("hardhat");
const BN = require("ethers").BigNumber;

describe("CHECK FACTORY CONTRACT", () => {
  let owner, signer1, signer2, admin, factory,proxy,proxy1,factory1;

  beforeEach(async () => {
    [owner, signer1, signer2, admin, cfo] = await ethers.getSigners();

    const TokenContract = await ethers.getContractFactory("TokenContract");
    token = await TokenContract.deploy();
    await token.deployed();

    const FactoryContract = await ethers.getContractFactory("FactoryContract");
    factory1 = await FactoryContract.deploy();
    await factory1.deployed();

    const Proxy = await ethers.getContractFactory("OwnedUpgradeabilityProxy")
    proxy = await Proxy.deploy();
    await proxy.upgradeTo(factory1.address);

    factory = await FactoryContract.attach(proxy.address)
    await factory.initialize(token.address, owner.address);
    
    // await factory.initialize(token.address, owner.address);



    await factory.connect(owner).addAdminRole(admin.address);
    console.log(fac
        .address
        )
  });
})