const { ethers } = require("hardhat");

async function main() {
  console.log("--- Sentinel Protocol: Authority Ledger Deployment ---");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const AuthorityLedger = await ethers.getContractFactory("AuthorityLedger");
  const ledger = await AuthorityLedger.deploy();

  await ledger.deployed();

  console.log("Authority Ledger deployed to:", ledger.address);
  console.log("Sentinel Protocol Status: LIVE ON-CHAIN");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
