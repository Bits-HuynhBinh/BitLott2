pragma solidity ^0.4.23;

import "truffle/Assert.sol"; 
import "truffle/DeployedAddresses.sol"; 
import "../contracts/LotteryContract.sol"; 
import "../contracts/Clock.sol"; 

contract TestLotteryContract
{
    uint public initialBalance = 10 ether;

    function begin() private returns(LotteryContract, Clock, Random)
    {
        Clock clock = Clock(DeployedAddresses.Clock());
        Random random = Random(DeployedAddresses.Random());
        LotteryContract lot = new LotteryContract(address(clock), address(random));

        return (lot, clock, random);
    }

    function testCreateRandomNumber() public
    {
        LotteryContract lot;
        Clock clock;
        Random random;

        (lot, clock, random) = begin();

        uint expected = 99999;
        uint rand = lot._findWinningNumber();

        Assert.isAbove(rand, expected, "Random number must be > 100.000");
    }

    function testContractUnlocked() public
    {
        LotteryContract lot;
        Clock clock;
        Random random;

        (lot, clock, random) = begin();

        bool check;
        check = lot.isContractUnlocked();
        Assert.equal(check, false, "ABC-Contract should be locked.");

        lot.setupContractFirstTime();
        check = lot.isContractUnlocked();
        Assert.equal(check, true, "ABC-Contract should be locked.");
    }

    function testContractEndTime() public
    {
        LotteryContract lot;
        Clock clock;
        Random random;

        (lot, clock, random) = begin();

        Assert.equal(lot._isCampaignEnd(), true, "Campaign must be in END state.");

        lot.setupContractFirstTime();
        lot.startNewCampaign();
        Assert.equal(lot._isCampaignEnd(), false, "Campaign must be in OPEN state.");

        uint duration = 3 days;
        clock.setNow(now + duration);
        Assert.equal(lot._isCampaignEnd(), true, "Campaign must be in END state.");
    }

    function testTicketPrice() public
    {
        LotteryContract lot;
        Clock clock;
        Random random;

        (lot, clock, random) = begin();

        Assert.equal(lot.campaignTicketPrice(), 0.01 ether, "Ticket price is not correct.");
        Assert.equal(lot.actualTicketPrice(), 0.009 ether, "Ticket price is not correct.");

        lot.updateTicketPrice(10 ether, 9 ether);
        Assert.equal(lot.campaignTicketPrice(), 10 ether, "Ticket price is not correct.");
        Assert.equal(lot.actualTicketPrice(), 9 ether, "Ticket price is not correct.");

        lot.updateTicketPrice(1 ether, 0.9 ether);
        Assert.equal(lot.campaignTicketPrice(), 1 ether, "Ticket price is not correct.");
        Assert.equal(lot.actualTicketPrice(), 0.9 ether, "Ticket price is not correct.");

    }

    function testCampaignDuration() public
    {
        LotteryContract lot;
        Clock clock;
        Random random;

        (lot, clock, random) = begin();

        Assert.equal(lot.campaignDuration(), 3 days, "TDuration must be 3 days.");

        lot.updateCampaignDuration(10 days);
        Assert.equal(lot.campaignDuration(), 10 days, "TDuration must be 10 days.");

        lot.updateCampaignDuration(1 days);
        Assert.equal(lot.campaignDuration(), 1 days, "TDuration must be 10 days.");

        lot.updateCampaignDuration(0 days);
        Assert.equal(lot.campaignDuration(), 0 days, "TDuration must be 10 days.");
    }


    function testFallback() public 
    {
        LotteryContract lot;
        Clock clock;
        Random random;

        (lot, clock, random) = begin();

        Assert.equal(address(lot).balance, 0, "Not equal");

        address(lot).transfer(5000)();
        //Assert.equal(address(lot).balance, 5000 wei, "Not equal");
    }








}