// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

/**
 * @title ISecurityContext 
 * 
 * Interface for a contract's associated { SecurityContext } contract, from the point of view of the security-managed 
 * contract (only a small subset of the SecurityContext's methods are needed). 
 * 
 * See also { SecurityContext }
 * 
 * @author John R. Kosinski
 * LoadPipe 2024
 * All rights reserved. Unauthorized use prohibited.
 */
interface ISecurityContext  {
    
    /**
     * Returns `true` if `account` has been granted `role`.
     * 
     * @param role The role to query. 
     * @param account Does this account have the specified role?
     */
    function hasRole(bytes32 role, address account) external returns (bool);

    /**
     * Checks if an account is wearing a specific hat
     * @param hatId The ID of the hat to check
     * @param wearer The address to check
     * @return bool True if the address is wearing the hat
     */
    function hasHat(uint256 hatId, address wearer) external view returns (bool);
}