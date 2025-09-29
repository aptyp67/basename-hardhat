import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", await deployer.getAddress());

  const Watchlist = await ethers.getContractFactory("Watchlist");
  const watchlist = await Watchlist.deploy();
  await watchlist.waitForDeployment();
  console.log("Watchlist:", await watchlist.getAddress());

  const registrar = process.env.REGISTRAR_ADDRESS!;
  const feeRecipient = process.env.FEE_RECIPIENT!;
  const feeBps = Number(process.env.FEE_BPS || "10");
  if (!registrar || !feeRecipient) throw new Error("Set REGISTRAR_ADDRESS / FEE_RECIPIENT");

  const RegisterWithFee = await ethers.getContractFactory("RegisterWithFee");
  const register = await RegisterWithFee.deploy(registrar, feeRecipient, feeBps);
  await register.waitForDeployment();
  console.log("RegisterWithFee:", await register.getAddress());
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
