// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./EscrowSetup.t.sol";

contract DeployTest is EscrowTestSetup {
    function testDeployWithParams() public {
        assertEq(admin, address(this));
        console.log("PaymentEscrow deployed at:", address(escrow));
    }
}