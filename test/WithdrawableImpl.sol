// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../src/utils/WithDrawable.sol";

contract WithDrawableImpl is WithDrawable {
    function withdraw(address payable to) external {
        _withdraw(to);
    }

    receive() external payable {}
}
