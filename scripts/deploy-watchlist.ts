import hardhat from "hardhat";

const { ethers } = hardhat;

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", await deployer.getAddress());

  const Watchlist = await ethers.getContractFactory("Watchlist");
  const watchlist = await Watchlist.deploy();
  await watchlist.waitForDeployment();
  console.log("Watchlist:", await watchlist.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
