import { SignerWithAddress } from "../node_modules/@nomiclabs/hardhat-ethers/signers";
import { ethers, network } from "hardhat";
import {
  expandTo18Decimals,
  expandTo6Decimals,
} from "../test/utilities/utilities";
import {
  Lottery2,
} from "../typechain";

function sleep(ms: any) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
async function main() {
  // We get the contract to deploy
  const lottery2 = await ethers.getContractFactory("Lottery2");
  const lottery = await lottery2.deploy();
  await sleep(4000);
  console.log("Lottery Deployed", lottery.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
   //Subscription id - 7850
   //SaitaAddress - 0x03CcfbE179286f8EDBd0d7660dd848a475960427 
  //SaitaAddress BSC - 0x6430dDbEF3511b18D933BF4f29E25D62Bb35b715 
