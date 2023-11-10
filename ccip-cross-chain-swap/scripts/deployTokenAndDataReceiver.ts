import { ethers, network, run } from "hardhat";

async function main() {
  if (network.name !== `ethereumSepolia`) {
    console.error(`Receiver must be deployed to Ethereum Sepolia`);
    return 1;
  }

  const sepoliaRouterAddress = `0xD0daae2231E9CB96b94C8512223533293C3693Bf`;

  await run("compile");

  const ccipTokenSenderFactory = await ethers.getContractFactory(
    "CCIPTokenAndDataReceiver"
  );
  const ccipTokenSender = await ccipTokenSenderFactory.deploy(
    sepoliaRouterAddress,
    100
  );

  await ccipTokenSender.deployed();

  console.log(
    `CCIPTokenAndDataReceiver deployed to ${ccipTokenSender.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
