//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Counter {
    uint public count;

    function increment() external {
        count += 1;
    }

    function decrease() external {
        count -= 1;
    }
}