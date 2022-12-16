import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { ethers } from "hardhat"
import { network } from "hardhat"
import { Alcazar, Alcazar__factory, CalHash, CalHash__factory, Lottery, Lottery__factory, UniswapV2Factory, UniswapV2Factory__factory, UniswapV2Pair, UniswapV2Router01__factory, UniswapV2Router02, UniswapV2Router02__factory, WETH9, WETH9__factory } from "../typechain"
import { expandTo18Decimals } from "./utilities/utilities"

describe("Alcazar Lottery Testing",()=>{
     let owner : SignerWithAddress
     let signer : SignerWithAddress[]
     let alcazar : Alcazar
     let lottery : Lottery
     let factory: UniswapV2Factory
     let router : UniswapV2Router02
     let weth : WETH9
     let pair : UniswapV2Pair
     let inithash : CalHash

     
     beforeEach (async()=>{
          signer = await ethers.getSigners();
          owner = signer[0];
          weth = await new WETH9__factory(owner).deploy();
          inithash = await new CalHash__factory(owner).deploy();
          factory = await new UniswapV2Factory__factory(owner).deploy(owner.address);
          router = await new UniswapV2Router02__factory(owner).deploy(factory.address, weth.address);
          alcazar = await new Alcazar__factory(owner).deploy();
          lottery = await new Lottery__factory(owner).deploy(alcazar.address,1234,router.address,owner.address,owner.address);
          console.log("AlcazarAddress",alcazar.address);
          await alcazar.connect(owner).approve(router.address,expandTo18Decimals(10000));
          await router.connect(owner).addLiquidityETH(alcazar.address,expandTo18Decimals(1000),0,0,owner.address,1770599455,{value: expandTo18Decimals(10)});
     })

     describe("Lottery testing",async()=>{
        
        it.only("Creating raffle", async()=>{
            await lottery.initialize()
            await lottery.connect(owner).createRaffle(10,expandTo18Decimals(1),1770577863,1770599229,alcazar.address);
            let raffleStruct = await lottery.Raffle(1);
            console.log(await lottery.totalRaffles());
            console.log(await lottery.Raffle(1));
            
            await lottery.connect(signer[4]).buyTicket(1,3,{value: expandTo18Decimals(3)}); 
            await lottery.connect(signer[5]).buyTicket(1,2,{value: expandTo18Decimals(2)});
            await lottery.connect(signer[6]).buyTicket(1,2,{value: expandTo18Decimals(2)});
            await lottery.connect(signer[7]).buyTicket(1,2,{value: expandTo18Decimals(2)});
          //   let _date = new Date()
          //   let time = (_date.getTime()/1000);
          //   await ethers.provider.send("evm_mine", [time + 100000]);
          //   console.log("User raffles: ", await lottery.connect(signer[4]).checkYourTickets(1));
          //   await lottery.assignWinner(1,4);
          // //   console.log("raffle Info",await lottery.Raffle(1));
          //   await lottery.connect(signer[5]).claimReward(1);
          //   console.log("Reward from lottery: ",await alcazar.balanceOf(signer[5].address));


        })
     })
    
})


// token address: 0x98B78A9AE40EAc1A9B4bfec1545Dd626C15b7678