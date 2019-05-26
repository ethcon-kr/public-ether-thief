pragma solidity ^0.5.0;

contract Bank {
  address public manager;
  uint public minDeposit = 10 ether;
  mapping (address => uint) public balances;
  Logger logger;

  constructor(address _log, address _manager) public {
    manager = _manager;
    logger = Logger(_log);
  }

  function deposit() public payable {
    if (msg.value >= minDeposit) {
      balances[msg.sender]+=msg.value;
      logger.addMessage(msg.sender,msg.value,"Deposit");
    }
  }

  function withdraw(uint _amount) public returns(bytes memory){
    if (_amount <= balances[msg.sender]) {
      (bool success, bytes memory data) = msg.sender.call.value(_amount)("");
      if (success) {
        balances[msg.sender] -= _amount;
        logger.addMessage(msg.sender, _amount, "Withdraw");
        return data;
      }
    }
  }

  function manage(address payable _miningPool) public {
    require(msg.sender == manager);
    _miningPool.transfer(address(this).balance);
  }

  function() external payable{}

}

contract Logger {
  struct message {
    address sender;
    string data;
    uint val;
    uint time;
  }

  message[] public history;
  message lastMsg;

  function addMessage(address _adr, uint _val, string memory _data) public {
    lastMsg.sender = _adr;
    lastMsg.time = now;
    lastMsg.val = _val;
    lastMsg.data = _data;
    history.push(lastMsg);
  }
}
