// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const pSBT = await hre.ethers.getContractFactory("PipeleSBT");
  const psbt = await pSBT.deploy();
  await psbt.deployed();

  console.log("Pipele deployed to: ", psbt.address);

  await sleep(120);

  await hre.run("verify:verify", {
    address: psbt.address,
    constructorArguments: [],
  });
}

function sleep(s) {
  return new Promise((resolve) => setTimeout(resolve, s * 1000));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
