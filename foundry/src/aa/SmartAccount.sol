// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract SmartAccount { 
    bytes32 id; 
    address bundler;
    address userEoa; 

    constructor(address _bundler, bytes32 _id, address _userEoa) {
        bundler = _bundler;
        id = _id;
        userEoa = _userEoa;
    }
}