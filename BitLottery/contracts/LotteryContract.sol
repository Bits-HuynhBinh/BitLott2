pragma solidity ^0.4.23;

import "./Clock.sol";
import "./Random.sol";

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
    event EventSetupFirstTimeFinish(address contractOwner, bool isContractUnlocked);
    event EventFoundWinner(address winner, uint lotteryNumber, uint campaignId);
    event EventBoughtTicket(address buyer, uint lotteryNumber, uint campaignId, uint ticketPrice, uint totalLotteryAmount);
    event EventStartNewCampaign(uint campaignId, uint campaignStartTime, uint campaignDuration , uint ticketPrice);
    event EventStopCurrentCampaign(uint campaignId, uint stopTime, uint totalAmount);
    event EventWinnerWithdrawMoney(address winner, uint amount, uint withdrawTime);
    event EventDeveloperWithdrawMoney(address developerAddress, uint amount, uint withdrawTime);
    event EventFoundRandomNumber(uint campaignId, uint randomNumber, uint time);
    event EventGetAllInfo(uint campaignId, uint campaignStartTime, uint campaignDuration, uint campaignEndTime, uint campaignTicketPrice, uint campaignTotalAmount, uint lotteryCount);
    event EventFallback(address sender, uint amount);
    // Event


    // Variable
    // Public
    address public owner;

    uint public campaignId = 0;
    uint public campaignDuration;
    uint public campaignStartTime;
    uint public campaignEndTime;
    uint public campaignTicketPrice;
    uint public actualTicketPrice;
    uint public totalWinningAmount;
    uint public totalMaintananceAmount;
    
    Lottery[] public allLottery;
    mapping(address => uint) public winnerBalances;

    Clock public clock;
    Random public random;
    // Public


    // Private
    bool public isContractUnlocked = false;
    uint public totalFromFallback;
    // Private
    // Variable


    // Constructor
    constructor(address _clockAddress, address _randomAddress) public 
    {
        owner = msg.sender;
        clock = Clock(_clockAddress);
        random = Random(_randomAddress);

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

        emit EventSetupFirstTimeFinish(msg.sender, isContractUnlocked);
    }

    function startNewCampaign() external onlyOwner onlyAfterContractUnlock returns(bool)
    {
        require(_isCampaignEnd() == true);

        require(campaignDuration > 0);
        require(campaignTicketPrice > 0);

        campaignId++;
        require(campaignId > 0);

        campaignStartTime = clock.getNow();
        campaignEndTime = clock.getNow() + campaignDuration;

        emit EventStartNewCampaign(campaignId, campaignStartTime, campaignDuration, campaignTicketPrice);

        return true;
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

        emit EventWinnerWithdrawMoney(msg.sender, balance, now);
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

    function getCurrentCampaignInfo() external view returns(uint)
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
        uint winningNumber = 0;
        winningNumber = _findWinningNumber();
        
        // if someone's number is correct, then deposit the amount to that address
        // find how many winners in this campaign
        uint count = 0;
        count = _countWinners(winningNumber);

        if(count > 0)
        {
            // if there is Winners, we will assign the amount to each winner, and reset the amount back to Zero
            uint amountToEachBuyer = 0;
            amountToEachBuyer = totalWinningAmount / count;
           
            // find Winners
            address[] memory winnerAddresses = new address[](count);
            uint winnerCount = 0;
            for(uint i = 0; i < allLottery.length; i++ )
            {
                if(allLottery[i].number == winningNumber)
                {
                    winnerAddresses[winnerCount] = allLottery[i].lotteryOwner;
                    winnerCount++;

                    if(winnerCount > count)
                    {
                        break;
                    }
                }
            }

            // RESET TOTAL AMOUNT TO ZERO, CAUSE THERE IS WINNERS.
            totalWinningAmount = 0;

            // assign amount to each Winner
            for(uint j = 0; j < winnerAddresses.length; j++)
            {
                winnerBalances[winnerAddresses[j]] += amountToEachBuyer;
            }

        }
        else
        {
             // if count = 0, there is no Winner, so that we keep the total amount accumulated to the next campaign
        }


        // START A NEW CAMPAIGN ???
    }

    function _isCampaignEnd() public view returns(bool)
    {
        return campaignEndTime <= clock.getNow();
    }

    function _countWinners(uint _winningNumber) internal view returns(uint)
    {
        uint winnerCount = 0;
        
        for(uint i = 0; i < allLottery.length; i++ )
        {
            if(allLottery[i].number == _winningNumber)
            {
                winnerCount++;
            }
        }
        
        return winnerCount;
    }

    function _findWinningNumber() public view returns (uint) 
    {
        //uint rand = 0;
        //uint minExpected = 99999;

        //while(rand <= minExpected)
        //{
        //rand = random.getRandomNumber(totalWinningAmount, campaignId, totalMaintananceAmount, campaignStartTime, campaignEndTime, now);
        //}

        return random.getRandomNumber(totalWinningAmount, campaignId, totalMaintananceAmount, campaignStartTime, campaignEndTime, now);
    }

    function _getTicketCount() public view returns(uint)
    {
        return allLottery.length;
    }
    // Function

}