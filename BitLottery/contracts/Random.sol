pragma solidity ^0.4.23;

contract Random
{
   
    uint randomNumber;

    function getRandomNumber(uint var1, uint var2, uint var3, uint var4, uint var5, uint var6) public view returns(uint)
    {
        if(randomNumber > 0)
        {
            return randomNumber;
        }

        return random6(var1, var2, var3, var4, var5, var6);
    }

    function setRandomNumber(uint _number) public
    {
        randomNumber = _number;
    }

    function random6(uint var1, uint var2, uint var3, uint var4, uint var5, uint var6) private view returns (uint) 
    {
        uint rand1 = uint(keccak256(abi.encodePacked(var1, now))) % 1000000;
        uint rand2 = uint(keccak256(abi.encodePacked(var2, now))) % 10000000;
        uint rand3 = uint(keccak256(abi.encodePacked(var3, now))) % 1000000;
        uint rand4 = uint(keccak256(abi.encodePacked(var4, now))) % 10000000;
        uint rand5 = uint(keccak256(abi.encodePacked(var5, now))) % 1000000;
        uint rand6 = uint(keccak256(abi.encodePacked(var6, now))) % 10000000;

        return (rand1 + rand2 + rand3 + rand4 + rand5 + rand6) % 1000000;
    }
}