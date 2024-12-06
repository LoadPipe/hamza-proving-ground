// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "./EscrowSetup.t.sol";

contract DeployTest is EscrowTestSetup {
    function testDeployWithParams() public {
        assertEq(admin, address(this));
        console.log("PaymentEscrow deployed at:", address(escrow));
        // Check payerToken received the correct amount of test tokens
        uint256 expectedBalance = 500_000 * 10**18; // From EscrowSetup.t.sol
        assertEq(testToken.balanceOf(payerToken), expectedBalance, "PayerToken should have received half of total supply");
    }

    function testGrantHats() public {
        vm.startPrank(admin);
        topHatId = hats.mintTopHat(admin, "tophat", "http://www.tophat.com/");
        
        // Verify the top hat was minted correctly
        assertEq(hats.isWearerOfHat(admin, topHatId), true);

        // Create arbiter hat as child of topHat
        uint256 arbiterHatId = hats.createHat(
            topHatId,
            "Arbiter Hat",
            _maxSupply,
            _eligibility,
            _toggle,
            true,
            "arbiter.com"
        );


        hats.mintHat(arbiterHatId, arbiter);

        // Verify arbiter is wearing their hat
        assertTrue(hats.isWearerOfHat(arbiter, arbiterHatId));

        vm.stopPrank();
    }

    function testPlaceMultiPayments() public {
        vm.startPrank(admin);
    
        // Create payment inputs
        PaymentInput[] memory payments = new PaymentInput[](2);
        payments[0] = PaymentInput({
            id: keccak256("0x01"),
            receiver: receiver,
            payer: payerETH,
            amount: 1 ether
        });
        payments[1] = PaymentInput({
            id: keccak256("0x02"),
            receiver: receiver,
            payer: payerToken,
            amount: 2 ether
        });

        MultiPaymentInput[] memory multiPayments = new MultiPaymentInput[](1);
        multiPayments[0] = MultiPaymentInput({
            currency: address(0), // Using native ETH
            payments: payments
        });

        // Place payments
        escrow.placeMultiPayments{value: 3 ether}(multiPayments);

        // Verify payments were stored correctly
        Payment memory payment1 = escrow.getPayment(keccak256("0x01"));
        Payment memory payment2 = escrow.getPayment(keccak256("0x02"));

        assertEq(payment1.payer, payerETH);
        assertEq(payment2.payer, payerToken);

        vm.stopPrank();
    }
}
