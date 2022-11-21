//SPDX-License-Identifier:UNLICENSED

pragma solidity ^0.8.0;// Audit change to be made.

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract Lottery is Ownable, ReentrancyGuard{
using SafeERC20 for IERC20;
uint public totalRaffles;   
IERC20 alcazarToken; 

struct User{
    address userAddress;
    uint ticketNo;
    bool isWinner;
}    

// Information regarding individual raffle will be stored in the following struct.
struct RaffleInfo{
    uint number;
    uint maxTickets;
    bool ticketBuyOption;// if true the ticket can be bought with alcazar, otherwise ether.
    uint ticketPrice;
    uint ticketCounter;
    uint startTime;
    uint endTime;
    bool raffleOver;
    address raffleRewardToken;
    address winner;
    uint rewardPercent; // How much of the total tokens or eth will be rewarded from the total ticket buying price. In BP 10000.
    mapping(uint=>User) userInfo;
    mapping(uint=>mapping(address=>UserTickets)) userTotalTickets;
}

struct UserTickets{
    uint[] ticketsNumber;
}

mapping(uint=>RaffleInfo) public Raffle;

constructor(IERC20 _alcazarToken) {
     alcazarToken = _alcazarToken;
}

function createRaffle(uint _maxTickets,bool _ticketBuyOption, uint _ticketPrice, uint _startTime, uint _endTime, address _rewardToken, uint _rewardBP) public onlyOwner{
    totalRaffles++;
    RaffleInfo storage raffleEntry = Raffle[totalRaffles];
    raffleEntry.maxTickets = _maxTickets;
    raffleEntry.ticketBuyOption = _ticketBuyOption;
    raffleEntry.number = totalRaffles;
    raffleEntry.ticketPrice = _ticketPrice;
    raffleEntry.startTime = _startTime;
    raffleEntry.endTime = _endTime;
    raffleEntry.raffleRewardToken = _rewardToken;
    raffleEntry.rewardPercent = _rewardBP;
}

function buyTicket(uint _raffleNumber, uint _noOfTickets)payable public nonReentrant {
      RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
      require(!raffleInfo.raffleOver,"Raffle already over!!");
      require(raffleInfo.ticketCounter + _noOfTickets <= raffleInfo.maxTickets,"Max amount of tickets exceeded!");
      if(raffleInfo.ticketBuyOption){alcazarToken.safeTransferFrom(msg.sender,address(this),_noOfTickets*raffleInfo.ticketPrice);}
      if(!raffleInfo.ticketBuyOption){
      require(msg.value==_noOfTickets*raffleInfo.ticketPrice,"Ticket fee exceeds amount!!");}
      for(uint i=1;i<=_noOfTickets;i++){
      raffleInfo.ticketCounter++;
      raffleInfo.userTotalTickets[raffleInfo.number][msg.sender].ticketsNumber.push(raffleInfo.ticketCounter);
      raffleInfo.userInfo[raffleInfo.ticketCounter].userAddress= msg.sender;
      raffleInfo.userInfo[raffleInfo.ticketCounter].ticketNo = raffleInfo.ticketCounter;
      }
}

 function declareWinner(uint _randomWinner, uint _raffleNumber) public onlyOwner {
      RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
      uint totalApplicants = raffleInfo.ticketCounter;
      uint winnerNo = (_randomWinner%totalApplicants)+1;
      address winner = raffleInfo.userInfo[winnerNo].userAddress;
      raffleInfo.winner = winner;
 }


}


