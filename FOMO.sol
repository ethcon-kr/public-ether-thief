import './SafeMath.sol';

pragma solidity ^0.5.0;

contract FOMO {
  using SafeMath for *;

  address public winner;
  uint public lockTime;

  constructor() public payable {
    lockTime = now.add(5 minutes);
  }

  function deposit() public payable returns(bool) {
    require(msg.value == 1 ether);
    winner = msg.sender;
    lockTime = lockTime.add(5 minutes);
    return true;
  }

  function withdraw() public returns(bool) {
    require(msg.sender == winner);
    require(now >= lockTime);
    msg.sender.transfer(address(this).balance);
    return true;
  }

  function getLockTime() public view returns(uint) {
    return lockTime;
  }

  function getNow() public view returns(uint) {
    return now;
  }
}
