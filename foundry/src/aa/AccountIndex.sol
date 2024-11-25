// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./SmartAccount.sol"; 

abstract contract AccountIndex { 
    mapping(bytes32 => address) private idToAddress;
    mapping(address => bytes32) private addressToId;
    address bundler;

    event AccountCreated (
        address indexed accountAddress
    );

    constructor(address _bundler) {
        bundler = _bundler;
    }

    function accountExists(address addr) external view returns (bool) {
        return addressToId[addr] != 0;
    }

    function createAccount(bytes32 id, address userEoa) external {
        if (msg.sender != bundler) 
            revert("Unauthorized");

        address accountAddress = address(new SmartAccount(bundler, id, userEoa)); 

        idToAddress[id] = accountAddress;
        addressToId[accountAddress] = id;

        emit AccountCreated(accountAddress);
    }
}