pragma solidity ^0.4.23;

import "truffle/Assert.sol"; 
import "truffle/DeployedAddresses.sol"; 
import "../contracts/LotteryContract.sol"; 
import "../contracts/Clock.sol"; 
import "../contracts/Anonymous.sol";


contract TestLottery2
{
    uint public initialBalance = 10 ether;

    function begin() private returns(LotteryContract, Clock, Random)
    {
        Clock clock = Clock(DeployedAddresses.Clock());
        Random random = Random(DeployedAddresses.Random());
        LotteryContract lot = new LotteryContract(address(clock), address(random));

        return (lot, clock, random);
    }

    function testWithdrawDeveloperAmount() public
    {
        LotteryContract lot;
        Clock clock;
        Random random;

        uint actualTicketPrice = 0.009 ether;
        uint qty = 0;
        uint ticketNumber = 0;
        uint sendValue = 0;

        (lot, clock, random) = begin();
        lot.setupContractFirstTime();
        lot.startNewCampaign();
        Assert.equal(lot._isCampaignEnd(), false, "Campaign must be in OPEN state.");


        // buy ticket 1
        ticketNumber = 112233;
        sendValue = 0.01 ether;
        lot.buyLottery.value(sendValue)(ticketNumber);
        qty++;
        Assert.equal(lot.totalWinningAmount(), (actualTicketPrice * qty), "ERROR");
        Assert.equal(lot.totalMaintananceAmount(), ((sendValue - actualTicketPrice) * qty), "ERROR");

        var (campaignId, number, price, owner) = lot.allLottery(qty-1);
        Assert.equal(lot._getTicketCount(), qty, "ERROR");
        Assert.equal(number, ticketNumber, "ERROR");


        // buy ticket 2
        ticketNumber = 123456;
        sendValue = 0.01 ether;
        lot.buyLottery.value(sendValue)(ticketNumber);
        qty++;
        Assert.equal(lot.totalWinningAmount(), (actualTicketPrice * qty), "ERROR");
        Assert.equal(lot.totalMaintananceAmount(), ((sendValue - actualTicketPrice) * qty), "ERROR");

        (campaignId, number, price, owner) = lot.allLottery(qty-1);
        Assert.equal(lot._getTicketCount(), qty, "ERROR");
        Assert.equal(number, ticketNumber, "ERROR");


        // buy ticket 3
        ticketNumber = 999999;
        sendValue = 0.01 ether;
        lot.buyLottery.value(sendValue)(ticketNumber);
        qty++;
        Assert.equal(lot.totalWinningAmount(), (actualTicketPrice * qty), "ERROR");
        Assert.equal(lot.totalMaintananceAmount(), ((sendValue - actualTicketPrice) * qty), "ERROR");

        (campaignId, number, price, owner) = lot.allLottery(qty-1);
        Assert.equal(lot._getTicketCount(), qty, "ERROR");
        Assert.equal(number, ticketNumber, "ERROR");


        //withdraw developer amount
        //1. check the amount
        uint devAmount = lot.totalMaintananceAmount();
        Assert.isAbove(devAmount, 0.002 ether, "ERROR");
        //2. withdraw the amount
        address developerAddress = new Anonymous();
        lot.withdrawDeveloperMoney(developerAddress);
        Assert.equal(developerAddress.balance, devAmount - 1, "ERROR");
        //Assert.equal(lot.totalMaintananceAmount(), 0, "ERROR");
    }

    function testWithdrawWinnerAmount() public
    {

    }

    function testFullFlow() public
    {

    }

    function testFindWinningNumber() public
    {
        
    }


}