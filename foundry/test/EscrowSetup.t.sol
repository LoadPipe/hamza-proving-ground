// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "../src/PaymentEscrow.sol";
import "../src/SystemSettings.sol";
import "../src/SecurityContext.sol";
import "../src/Interfaces/ISystemSettings.sol";
import "../src/Interfaces/ISecurityContext.sol";
import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TestSetup as HatsTestSetup} from "hats-protocol/test/HatsTestSetup.t.sol";

abstract contract EscrowTestVariables {
    PaymentEscrow escrow;
    ISecurityContext securityContext;
    ISystemSettings settings;

    // Test addresses
    address internal admin;
    address internal payerETH;
    address internal payerToken;
    address internal receiver;
    address internal arbiter;
    address internal unauthorized;
    address internal vaultAddress;

    // Test ERC20 token
    IERC20 internal testToken;

    // Test payment values
    uint256 internal paymentAmount;
    bytes32 internal paymentId;
    address internal nativeToken; // address(0) for native token

    // Fee settings
    uint256 internal feeBps; // basis points (100 = 1%)

    // Events to test
    event PaymentReceived(
        bytes32 indexed paymentId,
        address indexed to,
        address from,
        address currency,
        uint256 amount
    );

    event ReleaseAssentGiven(
        bytes32 indexed paymentId,
        address assentingAddress,
        uint8 assentType
    );

    event EscrowReleased(
        bytes32 indexed paymentId,
        uint256 amount,
        uint256 fee
    );

    event PaymentTransferred(
        bytes32 indexed paymentId,
        address currency,
        uint256 amount
    );

    event PaymentTransferFailed(
        bytes32 indexed paymentId,
        address currency,
        uint256 amount
    );
}

abstract contract EscrowTestSetup is EscrowTestVariables, HatsTestSetup {
    function setUp() public virtual override {
        super.setUp();

        admin = address(this);

        setUpEscrowVariables();
        bytes32 arbiterHatId = setUpHatTree();
        setUpEscrowContracts(arbiterHatId);
       
    }

    function setUpHatTree() internal returns (bytes32) {
        // Set up initial hat tree
        // Mint top hat to admin
        vm.startPrank(admin);
        topHatId = hats.mintTopHat(admin, "tophat", "http://www.tophat.com/");
        
        // Verify the top hat was minted correctly
        assertEq(hats.isWearerOfHat(admin, topHatId), true);

        // Create arbiter hat as child of topHat
        uint256 _arbiterHatId = hats.createHat(  // Rename to avoid shadowing
            topHatId,
            "Arbiter Hat", 
            _maxSupply,
            _eligibility,
            _toggle,
            true,
            "arbiter.com"
        );
        console2.log("Arbiter Hat ID:", _arbiterHatId);

        // Mint arbiter hat to arbiter address
        hats.mintHat(_arbiterHatId, arbiter);
        vm.stopPrank();

        bool isWearing = hats.isWearerOfHat(arbiter, _arbiterHatId);
        console2.log("Is arbiter wearing hat?", isWearing);


        return bytes32(_arbiterHatId);
    }

    function setUpEscrowVariables() internal {
        // Setup addresses
        payerETH = address(1);
        payerToken = address(2);
        receiver = address(3);
        arbiter = address(4);
        unauthorized = address(99);
        vaultAddress = address(5);

        // Setup payment values
        paymentAmount = 1 ether;
        paymentId = keccak256("testPayment");
        nativeToken = address(0);
        feeBps = 250; // 2.5%

        // Fund test addresses
        vm.deal(payerETH, 100 ether);
        vm.deal(receiver, 1 ether);
        vm.deal(arbiter, 1 ether);

    }

    function setUpEscrowContracts(bytes32 arbiterHatId) internal {
        // Deploy SecurityContext first (deployer as admin)
        SecurityContext _securityContext = new SecurityContext(admin, address(hats), arbiterHatId);
        securityContext = ISecurityContext(address(_securityContext));
        console2.log("SecurityContext deployed at:", address(_securityContext));

        // Deploy SystemSettings with SecurityContext and initial values
        SystemSettings _settings = new SystemSettings(
            securityContext,
            vaultAddress,
            feeBps
        );
        settings = ISystemSettings(address(_settings));
        console2.log("SystemSettings deployed at:", address(_settings));

        // Deploy mock ERC20 token for testing
        testToken = IERC20(deployMockERC20());
        // Transfer half of the minted tokens to payerToken
        uint256 transferAmount = 500_000 * 10**18; // Half of 1 million tokens
        testToken.transfer(payerToken, transferAmount);

        // Deploy PaymentEscrow with SecurityContext and SystemSettings
        escrow = new PaymentEscrow(
            securityContext,
            settings
        );
        console2.log("PaymentEscrow deployed at:", address(escrow));
    }

    function deployMockERC20() internal returns (address) {
        // Deploy a mock ERC20 token using OpenZeppelin's implementation
        TestERC20 token = new TestERC20();
        return address(token);
    }
    
}

contract TestERC20 is ERC20 {
    constructor() ERC20("Test Token", "TEST") {
        // Mint some initial supply to the deployer
        _mint(msg.sender, 1000000 * 10**18); // 1 million tokens
    }
}
