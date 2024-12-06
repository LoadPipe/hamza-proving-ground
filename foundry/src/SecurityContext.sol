// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "openzeppelin/contracts/access/AccessControl.sol";
import "./Interfaces/ISecurityContext.sol";
import "hats-protocol/src/Interfaces/IHats.sol";

/**
 * @title SecurityContext 
 * 
 * A contract which provides AccessControl (role-based security) for one or more other contracts. 
 * 
 * This contract itself offers generic role-based security. When associated with another contract (the managed 
 * contract, which holds a reference to this contract's address), the managed contract manages its own security 
 * by calling this contract's hasRole function. Then security for that contract is managed by using this contract's
 * grantRole, revokeRole, and renounceRole functions. 
 * 
 * This contract can manage security for multiple contracts at once. 
 * 
 * @author John R. Kosinski
 * LoadPipe 2024
 * All rights reserved. Unauthorized use prohibited.
 */
contract SecurityContext is AccessControl, ISecurityContext {
    bytes32 public constant ADMIN_ROLE = 0x0;
    bytes32 public ARBITER_HAT;
    IHats public immutable hatsContract;

    event ArbiterHatSet(bytes32 oldHat, bytes32 newHat);
    
    /**
     * Constructs the instance, granting the initial role(s). 
     */
    constructor(address admin, address _hatsContract, bytes32 _arbiterHat) {
        _grantRole(ADMIN_ROLE, admin);
        hatsContract = IHats(_hatsContract);
        ARBITER_HAT = _arbiterHat;
        emit ArbiterHatSet(0, _arbiterHat);
    }

    /**
     * Sets the Arbiter Hat ID. Only callable by admin.
     * @param hatId The new hat ID to set
     */
    function setArbiterHat(uint256 hatId) external onlyRole(ADMIN_ROLE) {
        bytes32 oldHat = ARBITER_HAT;
        ARBITER_HAT = bytes32(hatId);
        emit ArbiterHatSet(oldHat, ARBITER_HAT);
    }
    
    /**
     * Returns `true` if `account` has been granted `role`.
     * 
     * @param role The role to query. 
     * @param account Does this account have the specified role?
     */
    function hasRole(bytes32 role, address account) public view virtual override(AccessControl, ISecurityContext) returns (bool) {
        // If the role is ARBITER_HAT and it's not zero, check if the account wears that hat
        if (role == ARBITER_HAT && role != 0) {
            return hatsContract.isWearerOfHat(account, uint256(ARBITER_HAT));
        }
        
        return super.hasRole(role, account);
    }
    
    /**
     * See { AccessControl-renounceRole }
     * 
     * If `account` is the same as caller, ADMIN the role being revoked is ADMIN, then the function 
     * fails quietly with no error. This is to prevent admin from revoking their own adminship, in order 
     * to avoid a case in which there is no admin.
     * 
     * Emits: 
     * - {AccessControl-RoleRevoked}
     * 
     * Reverts: 
     * - {UnauthorizedAccess} if caller does not have the appropriate security role}
     * - 'AccessControl:' if `account` is not the same as the caller. 
     */
    function renounceRole(bytes32 role, address account) public virtual override  {
        if (role != ADMIN_ROLE) {
            super.renounceRole(role, account);
        }
    }
    
    /**
     * See { AccessControl-revokeRole }
     * 
     * Prevents admin from revoking their own admin role, in order to prevent the contracts from being 
     * orphaned, cast adrift on the ocean of life with no admin. 
     * 
     * If `account` is the same as caller, ADMIN the role being revoked is ADMIN, then the function 
     * fails quietly with no error. This is to prevent admin from revoking their own adminship, in order 
     * to avoid a case in which there is no admin.
     * 
     * Emits: 
     * - {AccessControl-RoleRevoked}
     * 
     * Reverts: 
     * - {UnauthorizedAccess} if caller does not have the appropriate security role}
     */
    function revokeRole(bytes32 role, address account) public virtual override  {
        if (account != msg.sender || role != ADMIN_ROLE) {
            super.revokeRole(role, account);
        }
    }
}