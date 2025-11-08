// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library Events {

    event DelegateSignerSet(bytes32 indexed brokerHash, address indexed delegateSigner, address indexed setter);
    event TradeCycleStarted(uint256 indexed tradeCycleId, uint256 honeyDeposit, uint256 startedAt, uint256 expiresAt);
    event TradeCyclePendingEnd(uint256 indexed tradeCycleId);
    event TradeCycleInit(uint256 indexed tradeCycleId);
    event TradeCycleEnded(uint256 indexed tradeCycleId, uint256 endedAt);

    event Deposit(address indexed user, uint256 indexed tradeCycleId, uint256 amount);
    error InsufficientFunds();
    error OperationFailed();
    error TradeNotMatured();
    error UserExceedMaxDepositAmount();
    error UserNotWhitelisted();
    error ZeroAddress();
    error ZeroAmount();
}
