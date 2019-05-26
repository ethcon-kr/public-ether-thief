pragma solidity ^0.5.0;

/**
 * Referred https://github.com/Overtorment/MetaMining/blob/master/MetaToken.sol
 */
contract Miner {
    uint256 constant public MINING_REWARD = 1 ether;
    uint256 public blockNumber = 0;
    uint256 public target = 0x00000fff00000000000000000000000000000000000000000000000000000000;
//    uint256 public target = 0x0fffffff00000000000000000000000000000000000000000000000000000000;
    uint256 public entropy;
    uint8 public difficultyIndex = 1;

    event Receive(uint256 _value);
    event DifficultyIncreased(uint256 _difficulty);
    event Mine(address indexed _miner, uint256 _reward, uint40 _seconds);
    event EntropyUpdated(uint256 _entropy);

    constructor() public {
        updateEntropy();
    }

    function updateEntropy() private {
        entropy = keccakUint(keccakUint(uint256(blockhash(block.number-1)) + uint256(block.coinbase) + uint256(block.timestamp) + entropy));
        emit EntropyUpdated(entropy);
    }

    function keccakUint(uint256 _input) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_input)));
    }

    /// pure, accepts randomness & nonce and returns hash as int (which should be compared to target)
    function hash(uint256 _nonce, uint256 _entropy) public pure returns (uint256){
        return uint256(keccak256(abi.encodePacked(_nonce + _entropy)));
    }

    /// pure, accepts randomness, nonce & target and returns boolian whether work is good
    function checkProofOfWork(uint256 _nonce, uint256 _entropy, uint256 _target) public pure returns (bool workAccepted){
        return uint256(hash(_nonce, _entropy)) < _target;
    }

    // accepts Nonce and tells whether it is good to mine
    function checkMine(uint256 nonce) public view returns (bool success) {
        return checkProofOfWork(nonce, entropy, target);
    }

    /*
        accepts nonce aka "mining field", checks if it passess proof of work,
        rewards if it does
    */
    function mine(uint256 nonce) public returns (bool success) {
        require(checkMine(nonce));

        emit Mine(msg.sender, MINING_REWARD, uint40(block.timestamp)); // issuing event to those who listens for it

        if(address(this).balance >= MINING_REWARD) {
            msg.sender.transfer(MINING_REWARD);
        } else {
            // Not enough Ether to pay
        }
        blockNumber += 1;
        updateEntropy();

        difficultyIndex = difficultyIndex << 1;
        if(difficultyIndex == 0) {
            difficultyIndex = 1;
            target = target >> 1;
            emit DifficultyIncreased(target);
        }
        return true;
    }

    function deposit() payable public {
        emit Receive(msg.value);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
