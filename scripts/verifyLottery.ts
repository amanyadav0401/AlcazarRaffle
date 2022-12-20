const hre = require("hardhat");
import {
    expandTo18Decimals,
    expandTo6Decimals,
  } from "../test/utilities/utilities";

async function main() {

    console.log("after");
  
    await hre.run("verify:verify", {
        address: "0x77555Ba9ceccF37874f9ba639816A586435A9EB0",
        constructorArguments: ["0x02d5D268F336053520A339e15cababF3ECD9575D",1234,"0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D","0x8008985282aCa5835F09c3ffE09C9B380b2cEFd0","0x8008985282aCa5835F09c3ffE09C9B380b2cEFd0"],
        contract: "contracts/Lottery.sol:Lottery",
      });
    
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});