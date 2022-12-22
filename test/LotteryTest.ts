import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { ethers } from "hardhat"
import { Alcazar, Alcazar__factory, CalHash, CalHash__factory, Lottery2, Lottery2__factory, UniswapV2Factory, UniswapV2Factory__factory, UniswapV2Router02, UniswapV2Router02__factory, WETH9, WETH9__factory } from "../typechain"
import { expandTo18Decimals } from "./utilities/utilities"

describe("",async()=>{


    let owner : SignerWithAddress
    let signers: SignerWithAddress[]
    let lottery : Lottery2
    let factory : UniswapV2Factory
    let router : UniswapV2Router02
    let weth : WETH9
    let alcazar : Alcazar
    
    beforeEach(async()=>{
        signers = await ethers.getSigners();
        owner = signers[0];
        factory = await new UniswapV2Factory__factory(owner).deploy(owner.address);
        weth = await new WETH9__factory(owner).deploy();
        router = await new UniswapV2Router02__factory(owner).deploy(factory.address,weth.address);
        alcazar = await new Alcazar__factory(owner).deploy();
        lottery = await new Lottery2__factory(owner).deploy();
        await alcazar.connect(owner).approve(router.address,expandTo18Decimals(100000));
        await router.connect(owner).addLiquidityETH(alcazar.address,expandTo18Decimals(10000),0,0,owner.address,1672192651,{value:expandTo18Decimals(10)});
        await lottery.connect(owner).initialize(1234,signers[8].address,owner.address,router.address,alcazar.address,alcazar.address,alcazar.address,weth.address,3000,500,5000);
    })


    it("Testing lottery", async()=>{
        await lottery.connect(signers[8]).createRaffle("Sample_Raffle",10,expandTo18Decimals(1),1671429016,1672429016,alcazar.address);

        await lottery.connect(signers[1]).buyTicket(1,1,{value:expandTo18Decimals(1)});
        await lottery.connect(signers[2]).buyTicket(1,2,{value:expandTo18Decimals(2)});
        await lottery.connect(signers[3]).buyTicket(1,4,{value:expandTo18Decimals(4)});
        await lottery.connect(signers[4]).buyTicket(1,1,{value:expandTo18Decimals(1)});

        await lottery.connect(signers[8]).createRaffle("New Raffle",10,expandTo18Decimals(1),1671429016,1672429016,lottery.address);

        await lottery.connect(signers[1]).buyTicket(2,4,{value:expandTo18Decimals(4)});

        console.log(await lottery.Raffle(1));

        console.log("Burn Amount: ",await lottery.totalBurnAmount());
        console.log("Burn AMount total: ",await lottery.totalBurnAmount());
        console.log("Burnamount per raffle :", await lottery.BurnAmountPerRaffle(1) );


        console.log("Burn amount in raffle 1 : ",await lottery.BurnAmountPerRaffle(1));
        console.log("Burn amount in raffle 2 : ",await lottery.BurnAmountPerRaffle(2));

        console.log("Check your tickets: ",await lottery.checkYourTickets(1,signers[2].address));
        await lottery.connect(owner).collectBurnReward(signers[8].address);
        


        console.log("OwnerBalance: ",await ethers.provider.getBalance(alcazar.address));



        let amount = await ethers.provider.getBalance(owner.address);


        console.log("lottery after: ",await ethers.provider.getBalance(lottery.address));
        let newBalance = await ethers.provider.getBalance(owner.address);

        console.log("Profit split wallets amount received: ",newBalance.sub(amount) );


        console.log("Alcazar amount on raffle: ",await alcazar.balanceOf(lottery.address));
        console.log("Alcazar amount on raffle after: ",await alcazar.balanceOf(lottery.address));
        console.log("Alcazar amount on raffle after claim: ",await alcazar.balanceOf(lottery.address));
        console.log("User amount on raffle after: ",await alcazar.balanceOf(signers[1].address));

        console.log("UserTickets", await lottery.checkYourTickets(1,signers[3].address));

        
    })
    
})