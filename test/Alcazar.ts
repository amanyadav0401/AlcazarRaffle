import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { ethers } from "hardhat"
import { Alcazar, Alcazar__factory, Lottery, Lottery__factory } from "../typechain"

describe("Alcazar Lottery Testing",()=>{
     let owner : SignerWithAddress
     let signer : SignerWithAddress[]
     let alcazar : Alcazar
     let lottery : Lottery
     
     beforeEach (async()=>{
          signer = await ethers.getSigners();
          owner = signer[0];
          alcazar = await new Alcazar__factory(owner).deploy();
          lottery = await new Lottery__factory(owner).deploy(alcazar.address);
          console.log("AlcazarAddress",alcazar.address);
     })

     describe("Lottery testing",async()=>{
        
        it.only("Creating raffle", async()=>{
            await lottery.connect(owner).createRaffle(10, false, 100000000000, 1669010831,1700546830,alcazar.address,2000);
            let raffleStruct = await lottery.Raffle(1);
            let raffleNo = await lottery.totalRaffles();
            console.log("raffleNo : "+raffleNo,"details are :",raffleStruct);
        })




     })
    
})