import { SignerWithAddress } from "../node_modules/@nomiclabs/hardhat-ethers/signers";
import { ethers, network } from "hardhat";
import {
  expandTo18Decimals,
  expandTo6Decimals,
} from "../test/utilities/utilities";
import {
  Lottery, Alcazar
} from "../typechain";

function sleep(ms: any) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
async function main() {
  // We get the contract to deploy
  const owner = "0x8a4E0e0C516B879084f047AE7428cA4a246Ad86A";

  const Alcazar = await ethers.getContractFactory("Alcazar");
  const alcazar = await Alcazar.deploy();
  await sleep(4000);
  const lottery = await ethers.getContractFactory("Lottery");
  const Lottery = await lottery.deploy(alcazar.address,"0x8008985282aCa5835F09c3ffE09C9B380b2cEFd0","0x8008985282aCa5835F09c3ffE09C9B380b2cEFd0","0x8008985282aCa5835F09c3ffE09C9B380b2cEFd0",1234,"0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6","0xE592427A0AEce92De3Edee1F18E0157C05861564");
  await sleep(4000);
//   await staking.initialize("0x6410285e47A98D5885169CB1f120BA976724C370");
  console.log("Lottery Deployed", Lottery.address);
  console.log("Alcazar deployed",alcazar.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });


//   Token1 0x82A902CA9F6690176bcb97a0ae7360A85317D51E
//   SaitaMask 0xaD254d1019D4db873Ca7eD0Ff253602bCe102589

// Lottery - 0xaB17B606a76d34d21c987CA408AC013E7243a1ec
//0x98Bc19979F86e16B2887d7A1B9f47F71849Da229