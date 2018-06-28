var LotteryContract = artifacts.require("./LotteryContract.sol");
var Clock = artifacts.require("./Clock.sol");
var Random = artifacts.require("./Random.sol");

const DAY = 3600 * 24;

module.exports = function(deployer) 
{
  deployer.deploy(Clock).then(function()
  {
    return deployer.deploy(Random).then(function()
    {
      return deployer.deploy(LotteryContract, Clock.address, Random.address);
    })
  });
};