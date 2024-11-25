// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SmartAccount { 
    bytes32 id; 
    address bundler;
    address userEoa; 

    constructor(address _bundler, bytes32 _id, address _userEoa) {
        bundler = _bundler;
        id = _id;
        userEoa = _userEoa;
    }

    function withdrawFunds(uint256 amount, address tokenAddress) external {
        if (msg.sender != userEoa) {
            revert("Unauthorized");
        }

        if (tokenAddress == address(0)) {
            IERC20 token = IERC20(tokenAddress); 
            token.transfer(userEoa, amount);
        }
        else {
            payable(userEoa).transfer(amount);
        }
    }
}