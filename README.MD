# piggybankthereum

A simple Ethereum-based Piggybank smart contract. Built with Foundry.

## Overview

Piggybankthereum is a minimal smart contract that allows:
- Deposits from anyone
- Time-locked withdrawals (only by the owner)
- Balance checking
- Test coverage

## Project Structure

- `/contracts` - Solidity smart contracts
  - `src/PiggyBank.sol` - Main contract implementation
  - `test/PiggyBank.t.sol` - Contract test suite
  - `script/Deploy.s.sol` - Deployment script

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

## Getting Started

1. Build:
```sh
forge build
```

1. Run tests:
```sh
forge test
```
## Future Plans

- React frontend integration
- Wallet support
- Network deployment scripts
