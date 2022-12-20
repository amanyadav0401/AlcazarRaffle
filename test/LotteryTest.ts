import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { ethers } from "hardhat"
import { Alcazar, Alcazar__factory, CalHash, CalHash__factory, Lottery, Lottery__factory, UniswapV2Factory, UniswapV2Factory__factory, UniswapV2Router02, UniswapV2Router02__factory, WETH9, WETH9__factory } from "../typechain"
import { expandTo18Decimals } from "./utilities/utilities"

describe("",async()=>{


    let owner : SignerWithAddress
    let signers: SignerWithAddress[]
    let lottery : Lottery
    let factory : UniswapV2Factory
    let router : UniswapV2Router02
    let weth : WETH9
    let getinit : CalHash
    let alcazar : Alcazar
    
    beforeEach(async()=>{
        signers = await ethers.getSigners();
        owner = signers[0];
        factory = await new UniswapV2Factory__factory(owner).deploy(owner.address);
        weth = await new WETH9__factory(owner).deploy();
        router = await new UniswapV2Router02__factory(owner).deploy(factory.address,weth.address);
        alcazar = await new Alcazar__factory(owner).deploy();
        lottery = await new Lottery__factory(owner).deploy(alcazar.address,1234,router.address,owner.address,owner.address);
        await alcazar.connect(owner).approve(router.address,expandTo18Decimals(100000));
        await router.connect(owner).addLiquidityETH(alcazar.address,expandTo18Decimals(10000),0,0,owner.address,1672192651,{value:expandTo18Decimals(10)});
        await lottery.connect(owner).initialize(owner.address,owner.address,signers[1].address,weth.address,3000,500,5000);
    })


    it("Testing lottery", async()=>{
        await lottery.connect(owner).createRaffle("Sample_Raffle",10,expandTo18Decimals(1),1671429016,1672429016,alcazar.address);
        console.log(await lottery.Raffle(1));
        await lottery.connect(signers[1]).buyTicket(1,3,{value:expandTo18Decimals(3)});
        await lottery.connect(signers[2]).buyTicket(1,2,{value:expandTo18Decimals(2)});
        await lottery.connect(signers[3]).buyTicket(1,4,{value:expandTo18Decimals(4)});
        await lottery.connect(signers[4]).buyTicket(1,1,{value:expandTo18Decimals(1)});

        console.log(await lottery.Raffle(1));

        console.log("OwnerBalance: ",await ethers.provider.getBalance(owner.address));

        let amount = await ethers.provider.getBalance(owner.address);

        await lottery.connect(signers[7]).splitProfit(1);

        console.log("lottery after: ",await ethers.provider.getBalance(lottery.address));
        let newBalance = await ethers.provider.getBalance(owner.address);

        console.log("Profit split wallets amount received: ",newBalance.sub(amount) );


        console.log("Alcazar amount on raffle: ",await alcazar.balanceOf(lottery.address));
         await lottery.assignWinner(1,3);
        console.log("Alcazar amount on raffle after: ",await alcazar.balanceOf(lottery.address));
        await lottery.connect(signers[1]).claimReward(1);
        console.log("Alcazar amount on raffle after claim: ",await alcazar.balanceOf(lottery.address));
        console.log("User amount on raffle after: ",await alcazar.balanceOf(signers[1].address));

        console.log("UserTickets", await lottery.checkYourTickets(1,signers[3].address));

        
    })
    
})