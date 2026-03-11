require("dotenv").config();
const { ethers } = require("ethers");

const RPC = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PROFIT_WALLET = process.env.PROFIT_WALLET;

const provider = new ethers.JsonRpcProvider(RPC);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

// Replace with ABI and Bytecode from compiling FlashLoanArbitrageV3.sol
const ABI = [ /* Paste your ABI here */ ];
const BYTECODE = "0x..."; // Paste your compiled bytecode here

async function main() {
    console.log("Deploying FlashLoanArbitrageV3...");

    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet);
    const contract = await factory.deploy(PROFIT_WALLET);

    await contract.waitForDeployment();

    console.log("✅ Contract deployed at:", await contract.getAddress());
}

main().catch((err) => {
    console.error(err);
    process.exit(1);
});
