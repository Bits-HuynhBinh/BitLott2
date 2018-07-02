pragma solidity ^0.4.23;

contract Anonymous
{
    uint public data;

    function setData(uint _data) public 
    {
        data = _data;
    }

    function() public payable {}
}