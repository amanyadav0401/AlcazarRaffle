const hre = require("hardhat");
import {
    expandTo18Decimals,
    expandTo6Decimals,
  } from "../test/utilities/utilities";

async function main() {

    console.log("after");
  
    await hre.run("verify:verify", {
        address: "0x4fcA6eEAf731d659465107D36E6c5BB11a004D81",
        constructorArguments: [],
        contract: "contracts/Lottery2.sol:Lottery2",
      });
    
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});