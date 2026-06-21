const { ethers } = require("hardhat")

async function main() {
  const [deployer] = await ethers.getSigners()
  console.log("Deploying with:", deployer.address)

  // ── 1. Deploy CGLT (deployer = minter initial pour seed liquidity) ──
  const CGLT = await ethers.getContractFactory("CGLT")
  const cglt = await CGLT.deploy(deployer.address)
  await cglt.waitForDeployment()
  const cgltAddr = await cglt.getAddress()
  console.log("CGLT deployed:", cgltAddr)

  // ── 2. Deploy MockUSDT (mint 1,000,000 USDT au deployer) ──
  const MockUSDT = await ethers.getContractFactory("MockUSDT")
  const usdt = await MockUSDT.deploy()
  await usdt.waitForDeployment()
  const usdtAddr = await usdt.getAddress()
  console.log("MockUSDT deployed:", usdtAddr)

  // ── 3. Deploy CGLTReserve avec la vraie adresse USDT ──
  const CGLTReserve = await ethers.getContractFactory("CGLTReserve")
  const reserve = await CGLTReserve.deploy(cgltAddr, usdtAddr)
  await reserve.waitForDeployment()
  const reserveAddr = await reserve.getAddress()
  console.log("CGLTReserve deployed:", reserveAddr)

  // ── 4. Alimente le pool : 700 USDT actifs + 200 urgence + 100 buffer ──
  const emergencyAmount = ethers.parseUnits("200", 6)
  await (await usdt.transfer(reserveAddr, ethers.parseUnits("1000", 6))).wait()
  await (await reserve.setEmergencyReserve(emergencyAmount)).wait()
  console.log("Pool funded: 1000 USDT (700 active + 200 emergency + 100 buffer)")

  // ── 5. Mint 10,000,000 CGLT dans la reserve pour les swaps USDT→CGLT ──
  const cgltLiquidity = ethers.parseUnits("10000000", 18)
  await (await cglt.mint(reserveAddr, cgltLiquidity, "initial-liquidity")).wait()
  console.log("Reserve seeded with 10,000,000 CGLT")

  // ── 6. Trésorerie custodiale = deployer (= minter défini au constructeur) ──
  // Le deployer (CGLT_MINTER_KEY côté backend) reste le minter du token : il
  // exécute mint/burn (dépôt/retrait) ET les swaps custodiaux. On lui mint donc
  // une réserve de CGLT (il détient déjà ~999,000 USDT après seed du pool).
  await (await cglt.mint(deployer.address, ethers.parseUnits("500000", 18), "treasury-seed")).wait()
  console.log("Treasury (deployer) seeded with 500,000 CGLT (USDT déjà détenu)")
  console.log("Minter =", deployer.address, "(backend mint/burn opérationnel)")

  console.log("\n── DEPLOYED ADDRESSES ──")
  console.log("CGLT_CONTRACT_ADDRESS=" + cgltAddr)
  console.log("USDT_ADDRESS=" + usdtAddr)
  console.log("CGLT_RESERVE_ADDRESS=" + reserveAddr)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
