require("dotenv").config();
const { ethers } = require("ethers");

// Load secrets from GitHub
const RPC = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PROFIT_WALLET = process.env.PROFIT_WALLET;

if (!RPC || !PRIVATE_KEY || !PROFIT_WALLET) {
  console.error("❌ Missing required secrets: RPC_URL, PRIVATE_KEY, PROFIT_WALLET");
  process.exit(1);
}

const provider = new ethers.JsonRpcProvider(RPC);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

// Replace these with your compiled contract ABI and BYTECODE from Remix
const ABI = [ /* Paste your ABI array here */ ];
const BYTECODE = "0x..."; // Paste your compiled bytecode here

async function main() {
  console.log("🚀 Deploying FlashLoanArbitrageV3...");

  const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet);
  const contract = await factory.deploy(PROFIT_WALLET);

  await contract.waitForDeployment();

  const deployedAddress = await contract.getAddress();
  console.log("✅ Contract deployed at:", deployedAddress);
}

main().catch((err) => {
  console.error("❌ Deployment failed:", err);
  process.exit(1);
});
