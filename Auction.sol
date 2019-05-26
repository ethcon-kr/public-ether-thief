pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(b != a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract Auction {
  using SafeMath for uint;

  uint public endTime;
  uint public highestBid;
  address public winner;

  mapping(address => bytes32) public bid;
  mapping(address => bool) public revealed;

  constructor() public payable {
    endTime = now + 5 seconds;
  }

  function commit(bytes32 _bid, uint _time) public returns(bool) {
    require(now < endTime);
    require(!revealed[msg.sender]);
    bid[msg.sender] = _bid;
    endTime = endTime.add(_time);
    return true;
  }

  function reveal(uint _value) public returns(bool) {
    require(keccak256(toBytes(_value)) == bid[msg.sender], "invalid value");
    highestBid = _value;
    winner = msg.sender;
    return true;
  }

  function claim() public payable returns(bool) {
    require(now > endTime);
    require(msg.sender == winner);
    require(msg.value == highestBid);
    msg.sender.transfer(address(this).balance);
    return true;
  }

  function getHash(bytes memory _value, uint _value1) public pure returns(bytes32, bytes memory){
    return (keccak256(_value), toBytes(_value1));
  }

  function getHighestBid() public view returns(uint) {
    return highestBid;
  }

  function getWinner() public view returns(address) {
    return winner;
  }

  function getEndTime() public view returns(uint) {
    return endTime;
  }

  function toBytes(uint256 x) public pure returns (bytes memory b) {
    b = new bytes(32);
    assembly { mstore(add(b, 32), x) }
  }
}
