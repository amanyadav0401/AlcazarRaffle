//SPDX-License-Identifier:UNLICENSED

pragma solidity ^0.8.0; // Audit change to be made.

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./VRFv2Consumer.sol";
import "./mock_router/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./libraries/RaffleInfo.sol";

contract Lottery2 is ReentrancyGuard, Initializable, VRFv2Consumer {
    using SafeERC20 for IERC20;
    uint256 public totalRaffles;
    uint256 public totalBurnAmount;
    address  payable public  profitWallet1;
    address  payable public profitWallet2;
    address public operator;
    address public admin;
    IERC20 alcazarToken;
    address WETH;
    IUniswapV2Router02 public router;
    uint16 public profitPercent; // in BP 10000.
    uint16 public burnPercent;
    uint16 public profitSplit1BP;
    uint public totalRevenue;

    mapping(uint256 => RaffleStorage.RaffleInfo) public Raffle;

    // stores ticket numbers for every user for a given raffle. RaffleNumber => UserAddress => UserTickets
    mapping(uint=>mapping(address=>RaffleStorage.UserTickets)) userTicketNumbersInRaffle; 

    mapping(uint=>uint) public BurnAmountPerRaffle;

    event RaffleCreated(uint _raffleNumber,string _raffleName, uint16 _maxTickets, uint256 _ticketPrice, uint256 _startTime, uint256 _endTime, uint16 rewardPercent, address _rewardToken) ; 
    
    event BurnWalletUpdated(address burnWallet);

    event BurnPercentUpdated(uint16 burnPercent);

    event ProfitWallet1Updated(address _profitWallet1);

    event ProfitWallet2Updated(address _profitWallet2);

    event ProfitSplitPercentUpdated(uint16 _split1BP, uint _split2BP);

    event BuyTicket(uint raffleNumber, address _buyer, uint16 _ticketStart, uint16 _ticketEnd);

    event RewardClaimed(address _to, address _rewardToken, uint _amount);

    event burnCollected(uint256 _amount, address _to);



    modifier onlyAdmin() {
        require(msg.sender == admin,"You are not the admin.");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator || msg.sender == admin,"You are not the operator.");
        _;
    }

    function initialize( uint64 subscriptionId,address _operator,
        address _admin, IUniswapV2Router02 _router,IERC20 _alcazarToken,
        address payable _profitWallet1, address payable _profitWallet2, address _weth, uint16 _profitPercent, 
        uint16 _burnPercent, uint16 _profitSplit1BP) external initializer{
         operator = _operator;
         admin = _admin;
         alcazarToken = _alcazarToken;
         router = _router;
         profitWallet1 = _profitWallet1;
         profitWallet2 = _profitWallet2;
         WETH = _weth;
         profitPercent = _profitPercent;
         burnPercent = _burnPercent;
         profitSplit1BP = _profitSplit1BP;
         initializeV2Consumer(subscriptionId);
    }

    function createRaffle(
        string memory _raffleName,
        uint16 _maxTickets,
        uint256 _ticketPrice,
        uint256 _startTime,
        uint256 _endTime,
        address _rewardToken
    ) public  onlyOperator{
        require(block.timestamp<_endTime,"Provide future time value.");
        totalRaffles++;
        RaffleStorage.RaffleInfo storage raffleEntry = Raffle[totalRaffles];
        raffleEntry.raffleName = _raffleName;
        raffleEntry.maxTickets = _maxTickets;
        raffleEntry.number = totalRaffles;
        raffleEntry.ticketPrice = _ticketPrice;
        raffleEntry.startTime = _startTime;
        raffleEntry.endTime = _endTime;
        raffleEntry.raffleRewardToken = _rewardToken;
        raffleEntry.burnPercent = burnPercent;
        raffleEntry.rewardPercent = 10000 - profitPercent -burnPercent;
        emit RaffleCreated(totalRaffles,_raffleName, _maxTickets, _ticketPrice, _startTime, _endTime, 10000 - profitPercent-burnPercent,_rewardToken);
    }

    function updateBurnPercent(uint16 _bp) external onlyAdmin{
        burnPercent = _bp;
        emit BurnPercentUpdated(burnPercent);
    }

    function updateProfit1Address(address payable _profitWallet1) external onlyAdmin{
        profitWallet1 = _profitWallet1;
        emit ProfitWallet1Updated(_profitWallet1);
    }

     function updateProfit2Address(address payable _profitWallet2) external onlyAdmin{
        profitWallet2 = _profitWallet2;
        emit ProfitWallet2Updated(_profitWallet2);
    }

    function updateProfitSplitPercent(uint16 _bp) external onlyAdmin{
        profitSplit1BP = _bp;
        emit ProfitSplitPercentUpdated(_bp, 10000 - _bp);
    }
    
   

    function checkYourTickets(uint _raffleNo, address _owner) external view returns(uint[] memory){
        
          return userTicketNumbersInRaffle[_raffleNo][_owner].ticketsNumber;
           
    }

    function buyTicket(uint256 _raffleNumber, uint16 _noOfTickets)
        external
        payable
        nonReentrant
    {
        RaffleStorage.RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
        require(raffleInfo.endTime>block.timestamp,"Buying ticket time over!");
        require(
            raffleInfo.ticketCounter + _noOfTickets <= raffleInfo.maxTickets,
            "Max amount of tickets exceeded!"
        );
        require(
            msg.value == _noOfTickets * raffleInfo.ticketPrice,
            "Ticket fee exceeds amount!!"
        );
        uint16 ticketStart = raffleInfo.ticketCounter +1;
        for (uint8 i = 1; i <= _noOfTickets; i++) {
            raffleInfo.ticketCounter+=1;
            userTicketNumbersInRaffle[_raffleNumber][msg.sender].ticketsNumber.push(raffleInfo.ticketCounter);
            
            raffleInfo.ticketOwner[raffleInfo.ticketCounter] = msg.sender;
        }
        totalBurnAmount += (msg.value*raffleInfo.burnPercent)/10000;
        BurnAmountPerRaffle[_raffleNumber] +=(msg.value*raffleInfo.burnPercent)/10000;
        splitProfit(_raffleNumber,_noOfTickets);
        emit BuyTicket(_raffleNumber, msg.sender,ticketStart, raffleInfo.ticketCounter );
    }


    function updateRewardToken(uint256 _raffleNumber, address _rewardToken)
        external
        onlyOperator
    {
        RaffleStorage.RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
        require(
            block.timestamp < raffleInfo.startTime,
            "Raffle already started."
        );
        raffleInfo.raffleRewardToken = _rewardToken;
    }

    function checkTicketOwner(uint _raffleNumber, uint16 _ticketNumber) external view returns(address){
           return Raffle[_raffleNumber].ticketOwner[_ticketNumber];
    }

    function splitProfit(uint _raffleNumber,uint16 _noOfTickets) internal   {
        RaffleStorage.RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
        uint totalAmount = _noOfTickets*raffleInfo.ticketPrice;
        uint16 profitpercent = 10000 - raffleInfo.rewardPercent - raffleInfo.burnPercent;
        uint profitAmount = (profitpercent*totalAmount)/10000;
        uint splitWallet1Amount = (profitAmount*profitSplit1BP)/10000;
        (bool sent,) =profitWallet1.call{value: splitWallet1Amount}("");
        (bool success,) = profitWallet2.call{value:profitAmount-splitWallet1Amount}("");
        require(sent && success);
    }

    function collectBurnReward(address _to) external nonReentrant returns(bool){
        uint amount = totalBurnAmount;
        totalBurnAmount = 0;
        (bool success,) = _to.call{value: amount}("");
        require(success);
        emit burnCollected(amount, _to);
        return success;
    }

    function declareWinner(uint256 _raffleNumber) external  onlyOperator{
        RaffleStorage.RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
        require(block.timestamp > raffleInfo.endTime,"Raffle not over yet!");
        uint256 totalTicketsSold = raffleInfo.ticketCounter;
        requestRandomWords();
        uint256 winnerTicketNumber = (s_requestId % totalTicketsSold) + 1;
        raffleInfo.winningTicket = winnerTicketNumber;
        raffleInfo.winner = raffleInfo.ticketOwner[winnerTicketNumber];
        uint256 reward = ((raffleInfo.ticketPrice * raffleInfo.ticketCounter) *
        raffleInfo.rewardPercent) / 10000;
        uint amount = swapRewardInToken(raffleInfo.raffleRewardToken, reward);
        raffleInfo.raffleRewardTokenAmount = amount;
        }

    function claimReward(uint256 _raffleNumber) external nonReentrant returns(bool){
        RaffleStorage.RaffleInfo storage raffleInfo = Raffle[_raffleNumber];
        require(msg.sender == raffleInfo.winner, "You are not the winner");
        bool success = IERC20(raffleInfo.raffleRewardToken).transfer(msg.sender, raffleInfo.raffleRewardTokenAmount);
        raffleInfo.raffleRewardTokenAmount = 0;
        emit RewardClaimed(msg.sender, raffleInfo.raffleRewardToken, raffleInfo.raffleRewardTokenAmount);
        return success;
    }

    function swapRewardInToken(address _rewardToken, uint _reward) internal returns(uint){
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = _rewardToken;
        uint[] memory amounts = router.swapExactETHForTokens{value: _reward}(0, path, address(this), block.timestamp+3600);
        return amounts[1];
    }

}
