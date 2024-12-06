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

    function ARBITER_HAT() external view returns (bytes32);

    /**
     * Sets the Arbiter Hat ID. Only callable by admin.
     * @param hatId The new hat ID to set
     */
    function setArbiterHat(uint256 hatId) external;
    
    /**
     * Returns `true` if `account` has been granted `role`.
     * 
     * @param role The role to query. 
     * @param account Does this account have the specified role?
     */
    function hasRole(bytes32 role, address account) view external returns (bool);

}