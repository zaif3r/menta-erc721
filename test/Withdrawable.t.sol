// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "./WithdrawableImpl.sol";

contract WithdrawableTest is Test {
    WithDrawableImpl impl;

    function setUp() public {
        impl = new WithDrawableImpl();
    }

    function testWithdraw() public {
        (bool sent, ) = address(impl).call{value: 1 ether}("");
        assertTrue(sent);

        impl.withdraw(payable(address(0xBEEF)));
        assertEq(address(0xBEEF).balance, 1 ether);
    }
}
