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
}
