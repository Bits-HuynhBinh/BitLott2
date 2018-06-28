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

        uint expected = 100000;
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

        clock.setNow(now + 3 days);
        Assert.equal(lot._isCampaignEnd(), true, "Campaign must be in END state.");
    }

}