// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { Script, console2 } from "forge-std/Script.sol";
import { PaymentEscrow } from "../src/PaymentEscrow.sol";
import { SecurityContext } from "../src/SecurityContext.sol";
import { SystemSettings } from "../src/SystemSettings.sol";

contract DeployEscrow is Script {
    function run() external {
        // Get deployment private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        // Configuration values
        address vaultAddress = vm.envOr("VAULT_ADDRESS", deployer); // Default to deployer if not set
        uint256 feeBps = vm.envOr("FEE_BPS", uint256(250)); // Default 2.5% fee (250 basis points)

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy SecurityContext first (deployer as admin)
        SecurityContext securityContext = new SecurityContext(deployer);

        // 2. Deploy SystemSettings with SecurityContext and initial values
        SystemSettings systemSettings = new SystemSettings(
            securityContext,
            vaultAddress,
            feeBps
        );

        // 3. Deploy PaymentEscrow with SecurityContext and SystemSettings
        PaymentEscrow paymentEscrow = new PaymentEscrow(
            securityContext,
            systemSettings
        );

        vm.stopBroadcast();

        // Log deployed addresses
        console2.log("Deployed contracts:");
        console2.log("SecurityContext:", address(securityContext));
        console2.log("SystemSettings:", address(systemSettings));
        console2.log("PaymentEscrow:", address(paymentEscrow));
    }
}