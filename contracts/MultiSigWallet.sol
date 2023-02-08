// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Approve(uint indexed owner, uint indexed txId);
    event Revoke(uint indexed owner, uint indexed txId);
    event Executde(uint indexed txId);

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
}
