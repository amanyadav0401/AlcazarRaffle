import { SignerWithAddress } from "../node_modules/@nomiclabs/hardhat-ethers/signers";
import { ethers, network } from "hardhat";
import {
  expandTo18Decimals,
  expandTo6Decimals,
} from "../test/utilities/utilities";
import {
  Lottery,
} from "../typechain";

function sleep(ms: any) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
async function main() {
  // We get the contract to deploy
  const lottery1 = await ethers.getContractFactory("Lottery");
  const lottery = await lottery1.deploy("0x02d5D268F336053520A339e15cababF3ECD9575D",1234,"0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D","0x8008985282aCa5835F09c3ffE09C9B380b2cEFd0","0x8008985282aCa5835F09c3ffE09C9B380b2cEFd0");
  await sleep(4000);
  console.log("Lottery Deployed", lottery.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

  //SaitaAddress - 0x03CcfbE179286f8EDBd0d7660dd848a475960427 
  //SaitaAddress BSC - 0x6430dDbEF3511b18D933BF4f29E25D62Bb35b715 
