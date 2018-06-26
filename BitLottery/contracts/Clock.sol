pragma solidity ^0.4.18;

contract Clock
{
    uint private timestamp;

    function getNow() public view returns(uint)
    {
        if(timestamp > 0)
        {
            return timestamp;
        }

        return now;
    }

    function setNow(uint _time) public
    {
        timestamp = _time;
    }

}