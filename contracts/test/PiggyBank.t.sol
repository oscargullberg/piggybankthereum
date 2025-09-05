// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {PiggyBank} from "../src/PiggyBank.sol";

error NotOwner();
error TooEarly(uint256 nowTs, uint256 unlockAt);
error NoFunds();
error TransferFailed();

contract PiggyBankTest is Test {
    address owner;
    address alice;
    address attacker;

    function setUp() public {
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        attacker = makeAddr("attacker");

        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(attacker, 100 ether);

        vm.txGasPrice(0);
    }

    function _deployAsOwner(uint256 daysLock) internal returns (PiggyBank p) {
        vm.startPrank(owner);
        p = new PiggyBank(daysLock);
        vm.stopPrank();
    }

    function test_DepositOwnerAndNonOwner() public {
        PiggyBank p = _deployAsOwner(0);

        vm.prank(owner);
        (bool s1, ) = address(p).call{value: 1 ether}("");
        assertTrue(s1);

        vm.prank(alice);
        (bool s2, ) = address(p).call{value: 0.5 ether}("");
        assertTrue(s2);

        assertEq(address(p).balance, 1.5 ether);
    }

    function test_WithdrawTooEarlyReverts() public {
        PiggyBank p = _deployAsOwner(3);
        vm.prank(owner);
        address(p).call{value: 1 ether}("");

        uint256 unlockAtTs = p.unlockAt();
        vm.expectRevert(abi.encodeWithSelector(TooEarly.selector, block.timestamp, unlockAtTs));
        vm.prank(owner);
        p.withdraw();
    }

    function test_WithdrawAfterTimeLockSucceeds() public {
        PiggyBank p = _deployAsOwner(2);
        vm.prank(owner);
        address(p).call{value: 2 ether}("");

        vm.warp(block.timestamp + 2 days);

        uint256 before = owner.balance;
        vm.prank(owner);
        p.withdraw();

        assertEq(address(p).balance, 0);
        assertEq(owner.balance, before + 2 ether);
    }

    function test_AttackerCannotWithdraw() public {
        PiggyBank p = _deployAsOwner(0);
        vm.deal(address(p), 1 ether);

        vm.prank(attacker);
        vm.expectRevert(NotOwner.selector);
        p.withdraw();
    }

    function test_NonOwnerDepositorCannotWithdraw() public {
        PiggyBank p = _deployAsOwner(0);
        vm.prank(alice);
        address(p).call{value: 1 ether}("");

        vm.prank(alice);
        vm.expectRevert(NotOwner.selector);
        p.withdraw();
    }

    function test_WithdrawNoFundsReverts() public {
        PiggyBank p = _deployAsOwner(0);

        vm.prank(owner);
        vm.expectRevert(NoFunds.selector);
        p.withdraw();
    }

    function test_DepositEmitsEvent() public {
        PiggyBank p = _deployAsOwner(0);

        vm.prank(alice);
        vm.expectEmit(true, false, false, true, address(p));
        emit PiggyBank.Deposited(alice, 1 ether);
        (bool ok, ) = address(p).call{value: 1 ether}("");
        assertTrue(ok);
    }

    function test_WithdrawEmitsEvent() public {
        PiggyBank p = _deployAsOwner(0);

        vm.prank(owner);
        address(p).call{value: 3 ether}("");

        vm.prank(owner);
        vm.expectEmit(true, false, false, true, address(p));
        emit PiggyBank.Withdrew(owner, 3 ether);
        p.withdraw();
    }
}
