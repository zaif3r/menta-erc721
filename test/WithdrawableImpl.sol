// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../src/utils/Withdrawable.sol";

contract WithdrawableImpl is Withdrawable {
    function withdraw(address payable to) external {
        _withdraw(to);
    }

    receive() external payable {}
}
