const hre = require("hardhat");

async function main() {
  const pSBT = await hre.ethers.getContractFactory("PipeleSBT");
  const psbt = await pSBT.deploy(
    "https://gateway.pinata.cloud/ipfs/QmZ6LMcxPSRdNti5m8Ki2BoAoY7KRJ42sPEo66xwZ2CfZm"
  );
  await psbt.deployed();

  console.log("Pipele deployed to: ", psbt.address);

  await sleep(120);

  await hre.run("verify:verify", {
    address: psbt.address,
    constructorArguments: [
      "https://gateway.pinata.cloud/ipfs/QmZ6LMcxPSRdNti5m8Ki2BoAoY7KRJ42sPEo66xwZ2CfZm",
    ],
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
