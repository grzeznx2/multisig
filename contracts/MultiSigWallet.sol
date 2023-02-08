// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    address[] public owners;
    mapping(address => bool) isOwner;
    mapping(uint256 => mapping(address => bool)) approved;
    uint public required;
    Transaction[] public transactions;

    modifier onlyOwner(){
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    modifier txExists(uint256 _txId){
        require(_txId < transactions.length, "Transactions does not exist");
        _;
    }

    modifier notApproved(uint256 _txId){
        require(!approved[_txId][msg.sender], "Tx already approved");
        _;
    }

    modifier notExecuted(uint256 _txId){
        require(!transactions[_txId].executed, "Tx already executed");
        _;
    }

    constructor(address[] memory _owners, uint256 _required){
        require(_owners.length > 0, "At least 1 owner required");
        require(_required > 0 && _required <= _owners.length, "Invalid required number of owners");

        for(uint256 i; i < _owners.length; i++){
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner is not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(address _to, uint256 _value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        }));

        emit Submit(transactions.length - 1);
    }

    function approve(uint256 _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId){
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(uint256 _txId) private view returns(uint256 count) {

        for(uint256 i; i < owners.length; i++){
            if(approved[_txId][owners[i]]){
                count++;
            }
        }
    }

    function execute(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
        require(_getApprovalCount(_txId) >= required, "Not enough approvals");

        Transaction memory transaction = transactions[_txId];
        transactions[_txId].executed = true;

        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Error ocurred");

        emit Execute(_txId);
    }
}
