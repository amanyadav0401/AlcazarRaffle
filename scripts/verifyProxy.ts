const hre = require("hardhat");
import {
    expandTo18Decimals,
    expandTo6Decimals,
  } from "../test/utilities/utilities";

async function main() {

    console.log("after");
  
    await hre.run("verify:verify", {
        address: "0xBfbb2a49203051f882399b56F4FC2D68887E482a",
        constructorArguments: [],
        contract: "contracts/OwnedUpgradeabilityProxy.sol:OwnedUpgradeabilityProxy",
      });
    
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});