require("dotenv/config");
const { ethers } = require("ethers");

const RPC = process.env.CGLT_NODE_URL || "http://104.248.166.144:8545";
const DEPLOYER_KEY = process.env.DEPLOYER_PRIVATE_KEY;
const CGLT_ADDRESS = process.env.CGLT_ADDRESS || "0x575805BD8E7B5700BD58796E28cCf4761794fcf0";
const RECIPIENT = process.env.RECIPIENT_ADDRESS;
const AMOUNT = process.env.AMOUNT || "10000"; // CGLT

const ABI = [
  "function transfer(address to, uint256 amount) returns (bool)",
  "function balanceOf(address) view returns (uint256)",
  "function decimals() view returns (uint8)"
];

async function main() {
  if (!DEPLOYER_KEY) throw new Error("DEPLOYER_PRIVATE_KEY manquante");
  if (!RECIPIENT)    throw new Error("RECIPIENT_ADDRESS manquante");

  const provider = new ethers.JsonRpcProvider(RPC);
  const signer   = new ethers.Wallet(DEPLOYER_KEY, provider);
  const cglt     = new ethers.Contract(CGLT_ADDRESS, ABI, signer);

  const decimals = await cglt.decimals();
  const amount   = ethers.parseUnits(AMOUNT, decimals);

  const nonce = await provider.getTransactionCount(signer.address, "pending");

  const feeData = await provider.getFeeData();
  console.log(`Envoi de ${AMOUNT} CGLT vers ${RECIPIENT}... (nonce: ${nonce}, gasPrice: ${feeData.gasPrice}n)`);
  const tx = await cglt.transfer(RECIPIENT, amount, {
    gasPrice: feeData.gasPrice || 1n,
    gasLimit: 65000,
    nonce: nonce
  });
  console.log(`Tx hash : ${tx.hash}`);
  await tx.wait();

  const balance = await cglt.balanceOf(RECIPIENT);
  console.log(`✅ Succès! Nouveau solde: ${ethers.formatUnits(balance, decimals)} CGLT`);
}

main().catch(console.error);
