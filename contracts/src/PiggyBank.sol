// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

error NotOwner();
error TooEarly(uint256 nowTs, uint256 unlockAt);
error NoFunds();
error TransferFailed();

contract PiggyBank {
    address public immutable owner;
    uint256 public immutable deployedAt;
    uint256 public immutable minDaysUntilWithdraw;

    event Deposited(address indexed sender, uint256 amount);
    event Withdrew(address indexed to, uint256 amount);

    constructor(uint256 _minDaysUntilWithdraw) {
        owner = msg.sender;
        deployedAt = block.timestamp;
        minDaysUntilWithdraw = _minDaysUntilWithdraw;
    }

    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    function unlockAt() public view returns (uint256) {
        return deployedAt + (minDaysUntilWithdraw * 1 days);
    }

    function timeLeft() external view returns (uint256) {
        uint256 ua = unlockAt();
        return block.timestamp >= ua ? 0 : ua - block.timestamp;
    }

    function withdraw() external {
        if (msg.sender != owner) revert NotOwner();
        if (minDaysUntilWithdraw > 0) {
            uint256 ua = unlockAt();
            if (block.timestamp < ua) revert TooEarly(block.timestamp, ua);
        }

        uint256 bal = address(this).balance;
        if (bal == 0) revert NoFunds();

        (bool ok,) = payable(owner).call{value: bal}("");
        if (!ok) revert TransferFailed();

        emit Withdrew(owner, bal);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
