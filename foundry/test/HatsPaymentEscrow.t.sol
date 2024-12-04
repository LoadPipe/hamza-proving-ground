// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PaymentEscrow.sol";
import "../src/SecurityContext.sol";
import "../src/SystemSettings.sol";
import "../src/Hats.sol";
import "./HatsTestSetup.t.sol";

contract DeployTest is TestSetup {
    function testDeployWithParams() public {
        assertEq(hats.name(), name);
    }
    //TODO: Test Deoployment of the payment escrow contract
}

contract DeployHatTreeTest is TestSetup {

}