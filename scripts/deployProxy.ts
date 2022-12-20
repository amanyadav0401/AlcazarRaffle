import { SignerWithAddress } from "../node_modules/@nomiclabs/hardhat-ethers/signers";
import { ethers, network } from "hardhat";
import {
  expandTo18Decimals,
  expandTo6Decimals,
} from "../test/utilities/utilities";
import {
  OwnedUpgradeabilityProxy,
} from "../typechain";

function sleep(ms: any) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
async function main() {
  // We get the contract to deploy
  const owner = "0x8008985282aCa5835F09c3ffE09C9B380b2cEFd0";

  const proxy1 = await ethers.getContractFactory("OwnedUpgradeabilityProxy");
  const proxy = await proxy1.deploy();
  await sleep(4000);
  console.log("Proxy Deployed", proxy.address);
  
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

  //SaitaAddress - 0xE6A55671c1b863b73cCd8ECAcf4fa8Db3D6FF1b7
  //ProxyAddress = 0xB5604fE7985F814DDfD6835082cE1D28FD2c85Ac 
  //Proxy BSCTest = 0xf539187098368B02915D0d8aB538a30D7Bc66147
