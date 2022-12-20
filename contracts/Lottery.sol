// //SPDX-License-Identifier:UNLICENSED

// pragma solidity ^0.8.0; // Audit change to be made.

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "./VRFv2Consumer.sol";
// import "./mock_router/interfaces/IUniswapV2Router02.sol";
// import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

// contract Lottery is ReentrancyGuard, Initializable, VRFv2Consumer {
//     using SafeERC20 for IERC20;
//     uint256 public totalRaffles;
//     address payable public  profitWallet1;
//     address payable public profitWallet2;
//     address public burnWallet;
//     address public operator;
//     address public admin;
//     IERC20 alcazarToken;
//     address WETH;
//     IUniswapV2Router02 public router;
//     uint16 public profitPercent; // in BP 10000.
//     uint16 public burnPercent;
//     uint16 public profitSplit1BP;
//     uint public totalRevenue;


//     // Information regarding individual raffle will be stored in the following struct.
//     struct RaffleInfo {
//         uint256 number;
//         string raffleName;
//         uint16 maxTickets;
//         uint256 ticketPrice;
//         uint16 ticketCounter;
//         uint256 startTime;
//         uint256 endTime;
//         address raffleRewardToken;
//         uint256 raffleRewardTokenAmount;
//         address winner;
//         uint256 winningTicket;
//         uint16 rewardPercent; // How much of the total tokens or eth will be rewarded from the total ticket buying price. In BP 10000.
//         uint16 burnPercent;
//         mapping(address => UserTickets) userTotalTickets;
//         mapping(uint256 => address) ticketOwner;
//         mapping(address=>uint) totalTicketsPerOwner;
//     }

//     struct UserTickets {
//         uint256[] ticketsNumber;
//     }


//     mapping(uint256 => RaffleInfo) public Raffle;

//     // stores ticket numbers for every user for a given raffle. RaffleNumber => UserAddress => UserTickets
//     mapping(uint=>mapping(address=>UserTickets)) userTicketNumbersInRaffle; 

//     event RaffleCreated(uint _raffleNumber,string _raffleName, uint16 _maxTickets, uint256 _ticketPrice, uint256 _startTime, uint256 _endTime, uint16 rewardPercent, address _rewardToken) ; 
    
//     event BurnWalletUpdated(address burnWallet);

//     event BurnPercentUpdated(uint16 burnPercent);

//     event ProfitWallet1Updated(address _profitWallet1);

//     event ProfitWallet2Updated(address _profitWallet2);

//     event ProfitSplitPercentUpdated(uint16 _split1BP, uint _split2BP);

//     event BuyTicket(uint raffleNumber, address _buyer, uint16 _ticketStart, uint16 _ticketEnd);

//     event RewardClaimed(address _to, address _rewardToken, uint _amount);

//     constructor(
//         IERC20 _alcazarToken,
//         uint64 subscriptionId,
//         IUniswapV2Router02 _router,
//         address _operator,
//         address _admin
//     ) VRFv2Consumer(subscriptionId) {
//         alcazarToken = _alcazarToken;
//         router = _router;
//         operator = _operator;
//         admin = _admin;
//     }

//     modifier onlyAdmin() {
//         require(msg.sender == admin,"You are not the admin.");
//         _;
//     }

//     modifier onlyOperator() {
//         require(msg.sender == operator || msg.sender == admin,"You are not the operator.");
//         _;
//     }

//     function initialize(address payable _profitWallet1, address payable _profitWallet2, address _burnWallet, address _weth, uint16 _profitPercent, uint16 _burnPercent, uint16 _profitSplit1BP) external initializer{
//          profitWallet1 = _profitWallet1;
//          profitWallet2 = _profitWallet2;
//          burnWallet = _burnWallet;
//          WETH = _weth;
//          profitPercent = _profitPercent;
//          burnPercent = _burnPercent;
//          profitSplit1BP = _profitSplit1BP;
//     }

//     function createRaffle(
//         string memory _raffleName,
//         uint16 _maxTickets,
//         uint256 _ticketPrice,
//         uint256 _startTime,
//         uint256 _endTime,
//         address _rewardToken
//     ) public  {
//         totalRaffles++;
//         RaffleInfo storage raffleEntry = Raffle[totalRaffles];
//         raffleEntry.raffleName = _raffleName;
//         raffleEntry.maxTickets = _maxTickets;
//         raffleEntry.number = totalRaffles;
//         raffleEntry.ticketPrice = _ticketPrice;
//         raffleEntry.startTime = _startTime;
//         raffleEntry.endTime = _endTime;
//         raffleEntry.raffleRewardToken = _rewardToken;
//         raffleEntry.burnPercent = burnPercent;
//         raffleEntry.rewardPercent = 10000 - profitPercent -burnPercent;
//         emit RaffleCreated(totalRaffles,_raffleName, _maxTickets, _ticketPrice, _startTime, _endTime, 10000 - profitPercent-burnPercent,_rewardToken);
//     }

//     function updateBurnWalletAddress(address _address) external  {
//         burnWallet = _address;
//         emit BurnWalletUpdated(burnWallet);
//     }

//     function updateBurnPercent(uint16 _bp) external  {
//         burnPercent = _bp;
//         emit BurnPercentUpdated(burnPercent);
//     }

//     function updateProfit1Address(address payable _profitWallet1) external {
//         profitWallet1 = _profitWallet1;
        
//         emit ProfitWallet1Updated(_profitWallet1);
//     }

//      function updateProfit2Address(address payable _profitWallet2) external {
//         profitWallet2 = _profitWallet2;

//         emit ProfitWallet2Updated(_profitWallet2);
//     }

//     function updateProfitSplitPercent(uint16 _bp) external {
//         profitSplit1BP = _bp;
//         emit ProfitSplitPercentUpdated(_bp, 10000 - _bp);
//     }
    
   

//     function checkYourTickets(uint _raffleNo, address _owner) external view returns(uint[] memory){
        
//           return userTicketNumbersInRaffle[_raffleNo][_owner].ticketsNumber;
           
//     }

//     function buyTicket(uint256 _raffleNumber, uint16 _noOfTickets)
//         external
//         payable
//         nonReentrant
//     {
//         RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
//         require(raffleInfo.endTime>block.timestamp,"Buying ticket time over!");
//         require(
//             raffleInfo.ticketCounter + _noOfTickets <= raffleInfo.maxTickets,
//             "Max amount of tickets exceeded!"
//         );
//         require(
//             msg.value == _noOfTickets * raffleInfo.ticketPrice,
//             "Ticket fee exceeds amount!!"
//         );
//         uint16 ticketStart = raffleInfo.ticketCounter +1;
//         for (uint8 i = 1; i <= _noOfTickets; i++) {
//             raffleInfo.ticketCounter+=1;
//             // raffleInfo
//             //     .userTotalTickets[msg.sender]
//             //     .ticketsNumber
//             //     .push(raffleInfo.ticketCounter);
//             userTicketNumbersInRaffle[_raffleNumber][msg.sender].ticketsNumber.push(raffleInfo.ticketCounter);
            
//             raffleInfo.ticketOwner[raffleInfo.ticketCounter] = msg.sender;
//         }
//         emit BuyTicket(_raffleNumber, msg.sender,ticketStart, raffleInfo.ticketCounter );
//         raffleInfo.totalTicketsPerOwner[msg.sender] += _noOfTickets;
//     }


//     function updateRewardToken(uint256 _raffleNumber, address _rewardToken)
//         external
    
//     {
//         RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
//         require(
//             block.timestamp < raffleInfo.startTime,
//             "Raffle already started."
//         );
//         raffleInfo.raffleRewardToken = _rewardToken;
//     }

//     function checkTicketOwner(uint _raffleNumber, uint16 _ticketNumber) external view returns(address){
//            return Raffle[_raffleNumber].ticketOwner[_ticketNumber];
//     }

//     function splitProfit(uint _raffleNumber) external nonReentrant {
//         RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
//         uint totalAmount = raffleInfo.ticketCounter*raffleInfo.ticketPrice;
//         uint16 profitpercent = 10000 - raffleInfo.rewardPercent - raffleInfo.burnPercent;
//         uint profitAmount = (profitpercent*totalAmount)/10000;
//         uint splitWallet1Amount = (profitAmount*profitSplit1BP)/10000;
//         profitWallet2.call{value:profitAmount-splitWallet1Amount}("");
//     }

//     function declareWinner(uint256 _raffleNumber) external  {
        
//         RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
//         require(block.timestamp > raffleInfo.endTime,"Raffle not over yet!");
//         uint256 totalTicketsSold = raffleInfo.ticketCounter;
//         requestRandomWords();
//         uint256 winnerTicketNumber = (s_requestId % totalTicketsSold) + 1;
//         raffleInfo.winningTicket = winnerTicketNumber;
//         raffleInfo.winner = raffleInfo.ticketOwner[winnerTicketNumber];
//         uint256 reward = ((raffleInfo.ticketPrice * raffleInfo.ticketCounter) *
//         raffleInfo.rewardPercent) / 10000;
//         uint amount = swapRewardInToken(raffleInfo.raffleRewardToken, reward);
//         raffleInfo.raffleRewardTokenAmount = amount;
        
        
//         }

//     // function assignWinner(uint _raffleNumber, uint _ticketNumber) external {
//     //     RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
//     //     // require(block.timestamp > raffleInfo.endTime,"Raffle not over yet!");
//     //     raffleInfo.winningTicket = _ticketNumber;
//     //     raffleInfo.winner = raffleInfo.ticketOwner[_ticketNumber];
//     //     uint256 reward = ((raffleInfo.ticketPrice * raffleInfo.ticketCounter) *
//     //     raffleInfo.rewardPercent) / 10000;
//     //     uint amount = swapRewardInToken(raffleInfo.raffleRewardToken, reward);
//     //     raffleInfo.raffleRewardTokenAmount = amount;
//     //     uint burn = ((raffleInfo.ticketPrice*raffleInfo.ticketCounter)*raffleInfo.burnPercent)/10000;
//     //     burnWallet.call{value: burn}("");
//     // }

//     function claimReward(uint256 _raffleNumber) external nonReentrant returns(bool){
//         RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
//         require(msg.sender == raffleInfo.winner, "You are not the winner");
//         bool success = IERC20(raffleInfo.raffleRewardToken).transfer(msg.sender, raffleInfo.raffleRewardTokenAmount);
//         emit RewardClaimed(msg.sender, raffleInfo.raffleRewardToken, raffleInfo.raffleRewardTokenAmount);
//         return success;
//     }

//     function swapRewardInToken(address _rewardToken, uint _reward) internal returns(uint){
//         address[] memory path = new address[](2);
//         path[0] = WETH;
//         path[1] = _rewardToken;
//         uint[] memory amounts = router.swapExactETHForTokens{value: _reward}(0, path, address(this), block.timestamp+3600);
//         return amounts[1];
//     }

// }
