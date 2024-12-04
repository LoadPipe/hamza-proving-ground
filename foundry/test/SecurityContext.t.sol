// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SecurityContext.sol";

contract SecurityContextTest is Test {
    SecurityContext public securityContext;
    address public admin;
    address public nonAdmin1;
    address public nonAdmin2;

    bytes32 constant ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000000;
    bytes32 constant ARBITER_ROLE = 0xbb08418a67729a078f87bbc8d02a770929bb68f5bfdf134ae2ead6ed38e2f4ae;
    bytes32 constant DAO_ROLE = 0x3b5d4cc60d3ec3516ee8ae083bd60934f6eb2a6c54b1229985c41bfb092b2603;

    function setUp() public {
        admin = address(1);
        nonAdmin1 = address(2);
        nonAdmin2 = address(3);
        
        vm.prank(admin);
        securityContext = new SecurityContext(admin, address(1));
    }

    function grantRole(address secMan, bytes32 role, address toAddress, address caller) internal {
        vm.prank(caller);
        SecurityContext(secMan).grantRole(role, toAddress);
    }

    function revokeRole(address secMan, bytes32 role, address fromAddress, address caller) internal {
        vm.prank(caller);
        SecurityContext(secMan).revokeRole(role, fromAddress);
    }

    function testDeployment() public {
        assertTrue(securityContext.hasRole(ADMIN_ROLE, admin));
        assertFalse(securityContext.hasRole(ADMIN_ROLE, nonAdmin1));
        assertFalse(securityContext.hasRole(ADMIN_ROLE, nonAdmin2));
    }

    function testGrantAdminToSelf() public {
        vm.prank(admin);
        securityContext.grantRole(ADMIN_ROLE, admin);

        assertTrue(securityContext.hasRole(ADMIN_ROLE, admin));
        assertFalse(securityContext.hasRole(ADMIN_ROLE, nonAdmin1));
        assertFalse(securityContext.hasRole(ADMIN_ROLE, nonAdmin2));
    }

    function testTransferAdmin() public {
        vm.prank(admin);
        securityContext.grantRole(ADMIN_ROLE, nonAdmin1);

        // Now there are two admins
        assertTrue(securityContext.hasRole(ADMIN_ROLE, admin));
        assertTrue(securityContext.hasRole(ADMIN_ROLE, nonAdmin1));
        assertFalse(securityContext.hasRole(ADMIN_ROLE, nonAdmin2));

        vm.prank(nonAdmin1);
        securityContext.revokeRole(ADMIN_ROLE, admin);

        // Now origin admin has had adminship revoked
        assertFalse(securityContext.hasRole(ADMIN_ROLE, admin));
        assertTrue(securityContext.hasRole(ADMIN_ROLE, nonAdmin1));
        assertFalse(securityContext.hasRole(ADMIN_ROLE, nonAdmin2));
    }

    // ... continue with other tests following same pattern

    function testRestrictions() public {
        vm.startPrank(admin);
        securityContext.grantRole(ARBITER_ROLE, admin);
        securityContext.grantRole(DAO_ROLE, admin);
        vm.stopPrank();

        // Test admin cannot renounce admin role
        vm.prank(admin);
        securityContext.renounceRole(ADMIN_ROLE, admin);
        assertTrue(securityContext.hasRole(ADMIN_ROLE, admin));

        // Test admin can renounce non-admin role
        vm.startPrank(admin);
        securityContext.renounceRole(ARBITER_ROLE, admin);
        securityContext.renounceRole(DAO_ROLE, admin);
        vm.stopPrank();

        assertFalse(securityContext.hasRole(ARBITER_ROLE, admin));
        assertFalse(securityContext.hasRole(DAO_ROLE, admin));
    }
}