import { ethers, network, run } from "hardhat";

async function main() {
  if (network.name !== `polygonMumbai`) {
    console.error(`ender must be deployed to Polygon Mumbai`);
    return 1;
  }

  const mumbaiRouterAddress = `0x70499c328e1E2a3c41108bd3730F6670a44595D1`;
  const mumbaiLinkAddress = `0x326C977E6efc84E512bB9C30f76E30c160eD06FB`;

  await run("compile");

  const ccipTokenSenderFactory = await ethers.getContractFactory(
    "CCIPTokenAndDataSender"
  );
  const ccipTokenSender = await ccipTokenSenderFactory.deploy(
    mumbaiRouterAddress,
    mumbaiLinkAddress
  );

  await ccipTokenSender.deployed();

  console.log(`CCIPTokenAndDataSender deployed to ${ccipTokenSender.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
