pragma solidity ^0.4.23;

import "./Clock.sol";

contract LotteryContract
{
    // Struct
    struct Lottery 
    {
        uint campaignId;
        uint number;
        uint price;
        address lotteryOwner;
    }
    // Struct

    // Event
    event EventFoundWinner(address winner, uint lotteryNumber, uint campaignId);
    event EventBoughtTicket(address buyer, uint lotteryNumber, uint campaignId, uint ticketPrice, uint totalLotteryAmount);
    event EventStartNewCampaign(uint campaignId, uint campaignStartTime, uint campaignDuration , uint ticketPrice);
    event EventStopCurrentCampaign(uint campaignId, uint stopTime, uint totalAmount);
    event EventWinnerWithdrawMoney(address winner, uint amount, uint withdrawTime, uint campaignId);
    event EventDeveloperWithdrawMoney(address developerAddress, uint amount, uint withdrawTime);
    event EventFoundRandomNumber(uint campaignId, uint randomNumber, uint time);
    event EventGetAllInfo(uint campaignId, uint campaignStartTime, uint campaignDuration, uint campaignEndTime, uint campaignTicketPrice, uint campaignTotalAmount, uint lotteryCount);
    event EventFallback(address sender, uint amount);
    // Event


    // Variable
    address public owner;

    bool private isContractUnlocked = false;

    uint public campaignId = 0;
    uint public campaignDuration;
    uint public campaignStartTime;
    uint public campaignEndTime;
    uint public campaignTicketPrice;

    uint public actualTicketPrice;

    uint public totalWinningAmount;
    uint public totalMaintananceAmount;
    uint private totalFromFallback;

    mapping(address => uint) public winnerBalances;
    Lottery[] public allLottery;

    Clock public clock;
    // Variable


    // Constructor
    constructor(address _clockAddress) public 
    {
        owner = msg.sender;
        clock = Clock(_clockAddress);

        campaignDuration = 3 days;
        campaignTicketPrice = 0.01 ether;

        actualTicketPrice = 0.009 ether;
    }
    // Constructor

    // Modifier
    modifier onlyOwner() 
    {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAfterContractUnlock()
    {
        require(isContractUnlocked == true);
        _;
    }
    // Modifier

    // Function
    function setupContractFirstTime() external onlyOwner
    {
        require(campaignId == 0);
        isContractUnlocked = true;  
    }

    function startNewCampaign() external onlyOwner onlyAfterContractUnlock returns(bool)
    {
        require(campaignDuration > 0);
        require(campaignTicketPrice > 0);

        campaignId++;
        require(campaignId > 0);

        campaignStartTime = clock.getNow();
        campaignEndTime = clock.getNow() + campaignDuration;

        emit EventStartNewCampaign(campaignId, campaignStartTime, campaignDuration, campaignTicketPrice);

        return true;
    }

    function stopCurrentCampaign() external onlyOwner onlyAfterContractUnlock
    {
    }

    function buyLottery(uint _lotteryNumber) external payable onlyAfterContractUnlock
    {
        require(msg.value >= campaignTicketPrice);
        require(_isCampaignEnd() == false);

        allLottery.push(Lottery(campaignId, _lotteryNumber, campaignTicketPrice, msg.sender));

        totalWinningAmount += actualTicketPrice;
        totalMaintananceAmount += (msg.value - actualTicketPrice);

        emit EventBoughtTicket(msg.sender, _lotteryNumber, campaignId, campaignTicketPrice, totalWinningAmount);
    }

    function withdrawWinnerMoney() external onlyAfterContractUnlock
    {
        require(campaignId > 0);
        require(winnerBalances[msg.sender] > 0);

        uint balance = winnerBalances[msg.sender];
        winnerBalances[msg.sender] = 0;
        msg.sender.transfer(balance);

        emit EventWinnerWithdrawMoney(msg.sender, balance, now, campaignId);
    }

    function withdrawDeveloperMoney(address _developerAddress) external onlyOwner 
    {
        require(_developerAddress != address(0));
        require(totalMaintananceAmount > 0);

        uint balance = totalMaintananceAmount;
        totalMaintananceAmount = 0;
        _developerAddress.transfer(balance);

        emit EventDeveloperWithdrawMoney(_developerAddress, balance, now);
    }

    function getCurrentCampaignInfo() external returns(uint)
    {
        emit EventGetAllInfo(campaignId, campaignStartTime, campaignDuration, campaignEndTime, campaignTicketPrice, totalWinningAmount, allLottery.length);
        return campaignId;
    }

    function() public payable 
    {
        totalFromFallback += msg.value;
        emit EventFallback(msg.sender, msg.value);
    }
    
    function updateTicketPrice(uint _newPrice, uint _newActualPrice) external onlyOwner 
    {
        require(_isCampaignEnd() == true);

        campaignTicketPrice = _newPrice;
        actualTicketPrice = _newActualPrice;
    }

    function updateCampaignDuration(uint _newDuration) external onlyOwner 
    {
        campaignDuration = _newDuration;
    }

    function _randomWinner() private 
    {
        // pick 6 pair of numbers

        // if someone's number is correct, then deposit the amount to that address

        // if noone correct, accumulate this campaign amount to next campaign

    }

    function _isCampaignEnd() private returns(bool)
    {
        return campaignEndTime <= clock.getNow();
    }
    // Function

}