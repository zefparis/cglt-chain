const { ethers } = require("hardhat")

async function main() {
  const usdtAddress = process.env.USDT_ADDRESS
  if (!usdtAddress) throw new Error("USDT_ADDRESS not set in .env")

  const [deployer] = await ethers.getSigners()
  console.log("Deploying with:", deployer.address)
  console.log("Using USDT:", usdtAddress)

  // ── 1. Deploy CGLT (deployer = minter initial) ──
  const CGLT = await ethers.getContractFactory("CGLT")
  const cglt = await CGLT.deploy(deployer.address)
  await cglt.waitForDeployment()
  const cgltAddr = await cglt.getAddress()
  console.log("CGLT deployed:", cgltAddr)

  // ── 2. Deploy CGLTReserve avec l'adresse USDT réelle ──
  const CGLTReserve = await ethers.getContractFactory("CGLTReserve")
  const reserve = await CGLTReserve.deploy(cgltAddr, usdtAddress)
  await reserve.waitForDeployment()
  const reserveAddr = await reserve.getAddress()
  console.log("CGLTReserve deployed:", reserveAddr)

  console.log("\n── DEPLOYED ADDRESSES ──")
  console.log("CGLT_CONTRACT_ADDRESS=" + cgltAddr)
  console.log("CGLT_RESERVE_ADDRESS=" + reserveAddr)
  console.log("USDT_ADDRESS=" + usdtAddress)
  console.log("\nNext steps:")
  console.log("1. Fund the reserve with real USDT")
  console.log("2. Set emergency reserve: reserve.setEmergencyReserve(amount)")
  console.log("3. Mint CGLT liquidity into the reserve: cglt.mint(reserveAddr, amount, 'initial-liquidity')")
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
