//SPDX-License-Identifier:UNLICENSED

pragma solidity ^0.8.7;

interface IRandomNumber {
    function requestRandomWords() external returns (uint256);

    function lastRequestId() external returns (uint256);
}

