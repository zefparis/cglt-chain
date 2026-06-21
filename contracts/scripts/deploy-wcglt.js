const hre = require("hardhat");

async function main() {
  const wCGLT = await hre.ethers.getContractFactory("wCGLT");
  const token = await wCGLT.deploy();
  await token.waitForDeployment();
  const address = await token.getAddress();
  console.log("wCGLT deployed to:", address);
}

main().catch(console.error);
