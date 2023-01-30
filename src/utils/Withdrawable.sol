// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

abstract contract Withdrawable {
    function _withdraw(address payable to) internal {
        (bool sent, ) = to.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw");
    }
}
