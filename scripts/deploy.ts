import { ethers, run } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
  const developerAddress = process.env.DEVELOPER_ADDRESS;

  if (!developerAddress) {
    throw new Error("Developer address not found in .env");
  }

  console.log("Deploying PiggyBankFactory with developer:", developerAddress);

  const PiggyBankFactory = await ethers.getContractFactory("PiggyBankFactory");
  const factory = await PiggyBankFactory.deploy(developerAddress);

  await factory.waitForDeployment();
  const address = await factory.getAddress();

  console.log("PiggyBankFactory deployed to:", address);

  // Wait for some block confirmations
  console.log("Waiting for block confirmations...");
  await new Promise(resolve => setTimeout(resolve, 30000));

  // Verify contract
  console.log("Verifying contract...");
  await run("verify:verify", {
    address: address,
    constructorArguments: [developerAddress],
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
