pragma solidity ^0.5.0;

contract AirdropWallet {
    address public owner;
    uint public currentBalance;

    constructor() public {
    }

    modifier ownerOnly() {
        require(owner == address(0) || msg.sender == owner);
        _;
    }

    function setOwner(address _owner) public ownerOnly {
        owner = _owner;
    }

    function deposit() public payable {
        currentBalance += msg.value;
    }

    function withdraw(uint256 _amount) public ownerOnly {
        require(address(this).balance != 0);
        currentBalance -= _amount;
        msg.sender.transfer(_amount);
        require(address(this).balance == currentBalance);
    }
}

contract AirdropFactory {
    address public owner;
    address[] public airdropAccounts;

    event NewWallet(address);

    constructor() public {
        owner = msg.sender;
    }

    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    function () payable external {
    }

    function addAirdropAccount(address _account) public ownerOnly {
        require(!isIncluded(_account));
        airdropAccounts.push(_account);
    }

    function claim() public {
        require(isIncluded(msg.sender));
        AirdropWallet wallet = new AirdropWallet();
        wallet.setOwner(msg.sender);
        wallet.deposit.value(30 ether)();
        emit NewWallet(address(wallet));
    }

    function isIncluded(address _account) public view returns (bool){
        bool included = false;
        for (uint i = 0; i < airdropAccounts.length; i ++) {
            if (airdropAccounts[i] == _account) {
                included = true;
            }
        }
        return included;
    }
}

