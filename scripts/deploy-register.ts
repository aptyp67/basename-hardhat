import hardhat from "hardhat";

const { ethers } = hardhat;

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", await deployer.getAddress());

  const registrar = process.env.REGISTRAR_ADDRESS;
  const feeRecipient = process.env.FEE_RECIPIENT;
  const feeBps = Number(process.env.FEE_BPS || "10");

  if (!registrar) throw new Error("Set REGISTRAR_ADDRESS in your environment");
  if (!feeRecipient) throw new Error("Set FEE_RECIPIENT in your environment");

  const RegisterWithFeeV3 = await ethers.getContractFactory(
    "RegisterWithFeeV3"
  );
  const register = await RegisterWithFeeV3.deploy(
    registrar,
    feeRecipient,
    feeBps
  );
  await register.waitForDeployment();
  console.log("RegisterWithFeeV3:", await register.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
