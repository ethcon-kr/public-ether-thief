pragma solidity ^0.5.0;

contract Hint {
  bool public assigned;
  bool public set;
  bytes32 private hint;
  bytes private step; // first one
  bytes32 private tip;
  bytes32 private ethcon;
  uint[] private plain;

  HintReward public rewardPool;

  constructor(bytes32 _hint, bytes32 _tip, bytes32 _ethcon, uint[] memory _plain, address _rewardPool) public {
    set = true;
    hint = _hint;
    tip = _tip;
    ethcon = _ethcon;
    plain = _plain;
    rewardPool = HintReward(_rewardPool);
  }

  function assign(bytes32 _hint, bytes memory _step) public returns(bool) {
    require(!assigned);
    require(_hint == hint);
    set = true;
    assigned = true;
    step = _step;
    return true;
  }

  function claim(uint[] memory _answer) public {
    (bool success, bytes memory returnedData) = address(rewardPool).call(abi.encodeWithSelector(rewardPool.check.selector, _answer, plain, step));
    require(returnedData.length >= 0);
    require(success);
  }

  function help() public payable {
    require(msg.value >= 10 ether);
    (bool success, ) = address(rewardPool).call(abi.encodeWithSelector(rewardPool.help.selector));
    require(success);
  }
}
