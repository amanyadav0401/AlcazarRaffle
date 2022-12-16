const hre = require("hardhat");
import {
    expandTo18Decimals,
    expandTo6Decimals,
  } from "../test/utilities/utilities";

async function main() {

    
    // console.log("in main");
    // await hre.run("verify:verify", {
    //   address: "0x82A902CA9F6690176bcb97a0ae7360A85317D51E",
    //   constructorArguments: ["Tokn1",
    //   "TK1",
    //   expandTo18Decimals(200000)],
    //   contract: "contracts/Token1.sol:Token1",
    // });

    console.log("after");
  
    await hre.run("verify:verify", {
        address: "0x02d5D268F336053520A339e15cababF3ECD9575D",
        constructorArguments: [],
        contract: "contracts/token.sol:Alcazar",
      });
    
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});