// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
const Hre = require("hardhat");

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
function expandTo18Decimals(n) {
  return BigNumber.from(n).mul(BigNumber.from(10).pow(18));
}

async function main() {
  // let impl = await hre.ethers.getContractFactory("MEMEKONG");
  // let proxy = await hre.ethers.getContractFactory("MEMEKongProxy");

  // const Weth9 = await ethers.getContractFactory("WETH9");
  // const Pair = await ethers.getContractFactory("UniswapV2Pair");
  // const Factory = await ethers.getContractFactory("UniswapV2Factory");
  // const Router = await ethers.getContractFactory("UniswapV2Router02");
  const BuyContract = await ethers.getContractFactory("BuyContract");
  // const Tax_token = await ethers.getContractFactory("tax_token");
  // const DummyToken = await ethers.getContractFactory("DummyToken");
  // const CallHash = await ethers.getContractFactory("CalHash");
  const OwnedUpgradeabilityProxy = await ethers.getContractFactory(
    "BotProxy"
  );
  // const Impl = await impl.deploy();
  // console.log("Implementation: ",Impl.address);

  // const Proxy = await proxy.deploy();
  // console.log("Proxy: ",Proxy.address);

  // // await Proxy.upgradeTo(Impl.address);

  // factory = await Factory.deploy("0x4b6fe7658879363823E193363ABa6faF95fA262f");
  // await factory.deployed();
  // console.log("Factory: ", factory.address);

  // pair = await Pair.deploy();
  // await pair.deployed();
  // console.log("Pair: ", pair.address);

  // weth9 = await Weth9.deploy();
  // await weth9.deployed();
  // console.log("WETH: ", weth9.address);

  // router = await Router.deploy(factory.address, weth9.address);
  // await router.deployed();
  // console.log("Router: ", router.address);

  // let tax_token = await Tax_token.deploy();
  // await sleep(6000);
  // tax_tokenAddress = await tax_token.getAddress();
  // console.log("tax_tokenAddress: ", tax_tokenAddress);

  let buyContract = await BuyContract.deploy();
  await sleep(6000);
  buyContractAddress = await buyContract.getAddress();
  console.log("BuyContract: ", buyContractAddress);

  // let buyContractAddress = "0x77946287D5871daAD9418bA37481DD5A421b864c"

  let proxy = await OwnedUpgradeabilityProxy.deploy();
  await sleep(6000);
  proxyAddress = await proxy.getAddress();
  console.log("proxy address", proxyAddress);

  console.log("uprade before");
  await proxy.upgradeTo(buyContractAddress);
  await sleep(6000);

  let proxy1 = BuyContract.attach(proxyAddress);
  console.log("proxy1", await proxy1.getAddress());

  // await proxy1.initialize()

  // let dummyToken = await DummyToken.deploy();
  // await sleep(6000);
  // console.log("DummyTOken: ", await dummyToken.getAddress());

  // calHash = await CallHash.deploy();
  // console.log("callHash", await calHash.getInitHash());
  // await sleep(6000);

  //verify

  // sleep(6000);

  // await dummyToken.approve(router.address, expandTo18Decimals(100000));
  // await sleep(6000);
  // await weth9.approve(router.address, expandTo18Decimals(1));
  // await sleep(6000);
  // await router
  //   .connect()
  //   .addLiquidity(
  //     weth9.address,
  //     dummyToken.address,
  //     expandTo18Decimals(1),
  //     expandTo18Decimals(100000),
  //     expandTo18Decimals(1),
  //     expandTo18Decimals(1),
  //     "0x14ef97a0a27EeDDFd9A1499FD7ef99b52F8C7452",
  //     1686307329
  //   );
  // await sleep(6000);
  console.log("COmpleted ");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
