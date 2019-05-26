pragma solidity ^0.5.0;

contract Storage {
  mapping (uint => mapping (uint => Key)) private keychain;

  struct Key {
    uint counter;
    bytes32 privKey;
  }

  constructor(bytes32 _privKey0, bytes32 _privKey1, bytes32 _privKey2, bytes32 _privKey3, bytes32 _privKey4) public {
    keychain[0][0].privKey = _privKey0;
    keychain[0][1].privKey = _privKey1;
    keychain[0][2].privKey = _privKey2;
    keychain[0][3].privKey = _privKey3;
    keychain[0][4].privKey = _privKey4;
  }
}

contract Vault {
  VaultLib public vaultLibrary;
  uint public counter;
  address public owner;
  uint public lockTime;

  constructor(address _vaultLibrary, address _owner) public {
    vaultLibrary = VaultLib(_vaultLibrary);
    owner = _owner;
    lockTime = now + 5 seconds;
  }

  function withdraw() public returns(bool){
    require(msg.sender == owner);
    require(now > lockTime);
    msg.sender.transfer(counter * 1 ether);
    counter++;
    lockTime = now + 5 seconds;
    return true;
  }

  function() external payable {
    require(msg.sender == owner);
    (bool success,) = address(vaultLibrary).delegatecall(msg.data);
    require(success);
  }
}

contract VaultLib {
  address public vault;
  uint public counter;

  function setVault(address _vault) public {
    vault = _vault;
  }

  function addCounter() public {
    counter++;
  }
}
