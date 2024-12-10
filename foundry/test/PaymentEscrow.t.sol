// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "./EscrowSetup.t.sol";

contract DeployTest is EscrowTestSetup {
    function testDeployWithParams() public {
        assertEq(admin, address(this));
        //Check that the arbiter hat was created and the arbiter is wearing it
        uint256 arbiterHatId = uint256(securityContext.ARBITER_HAT());
        assertTrue(hats.isWearerOfHat(arbiter, arbiterHatId));
        // Check payerToken received the correct amount of test tokens
        uint256 expectedBalance = 500_000 * 10**18; // From EscrowSetup
        assertEq(testToken.balanceOf(payerToken), expectedBalance, "PayerToken should have received half of total supply");
    }

    function testTransferArbiterHat() public {
        uint256 arbiterHatId = uint256(securityContext.ARBITER_HAT());

        
        // Verify initial arbiter is wearing the hat
        assertTrue(hats.isWearerOfHat(arbiter, arbiterHatId));
        
        // Set up new arbiter address
        address newArbiter = address(0x123);
        
        // Transfer hat to new arbiter
        vm.prank(admin);
        hats.transferHat(arbiterHatId, arbiter, newArbiter);
        
        // Verify hat was transferred correctly
        assertFalse(hats.isWearerOfHat(arbiter, arbiterHatId), "Original arbiter should no longer wear hat");
        assertTrue(hats.isWearerOfHat(newArbiter, arbiterHatId), "New arbiter should now wear hat");
        
        // Verify security context still points to same hat ID
        assertEq(uint256(securityContext.ARBITER_HAT()), arbiterHatId, "Arbiter hat ID should not change");
    }

    function testPlaceAndReleaseMultiPayments() public {
        // Store the actual hash values first
        bytes32 ethPaymentId = keccak256(abi.encodePacked("0x01"));
        bytes32 tokenPaymentId = keccak256(abi.encodePacked("0x02"));
        

        // Create ETH payment input
        PaymentInput[] memory ethPayments = new PaymentInput[](1);
        ethPayments[0] = PaymentInput({
            id: ethPaymentId,
            receiver: receiver,
            payer: payerETH,
            amount: 1 ether
        });

        MultiPaymentInput[] memory ethMultiPayment = new MultiPaymentInput[](1);
        ethMultiPayment[0] = MultiPaymentInput({
            currency: address(0), // Using native ETH
            payments: ethPayments
        });

        // Place ETH payment
        vm.startPrank(payerETH);
        // Test PaymentReceived event emission for ETH payment
        vm.expectEmit(true, true, false, true);
        emit PaymentReceived(
            ethPaymentId, // indexed paymentId
            receiver,          // indexed to 
            payerETH,         // from
            address(0),       // currency (0x0 for ETH)
            1 ether          // amount
        );
        escrow.placeMultiPayments{value: 1 ether}(ethMultiPayment);
        vm.stopPrank();

        assertEq(address(escrow).balance, 1 ether, "Escrow should have 1 ETH");

        // Test PaymentReceived event emission for token payment  

        // Create token payment input
        PaymentInput[] memory tokenPayments = new PaymentInput[](1);
        tokenPayments[0] = PaymentInput({
            id: tokenPaymentId, 
            receiver: receiver,
            payer: payerToken,
            amount: 1000 * 10**18
        });

        MultiPaymentInput[] memory tokenMultiPayment = new MultiPaymentInput[](1);
        tokenMultiPayment[0] = MultiPaymentInput({
            currency: address(testToken), // Using mock token
            payments: tokenPayments
        });

        // Approve token spending and place token payment
        vm.startPrank(payerToken);
        testToken.approve(address(escrow), 1000 * 10**18);
        vm.expectEmit(true, true, false, true);
        emit PaymentReceived(
            tokenPaymentId,    // indexed paymentId
            receiver,             // indexed to
            payerToken,          // from
            address(testToken),   // currency
            1000 * 10**18        // amount
        );
        escrow.placeMultiPayments(tokenMultiPayment);
        vm.stopPrank();

        assertEq(testToken.balanceOf(address(escrow)), 1000 * 10**18, "Escrow should have 1000 tokens");

        // Verify payments were stored correctly
        Payment memory payment1 = escrow.getPayment(keccak256("0x01"));
        Payment memory payment2 = escrow.getPayment(keccak256("0x02"));

        // Verify payment details
        assertEq(payment1.payer, payerETH);
        assertEq(payment1.id, ethPaymentId);
        assertEq(payment2.payer, payerToken); 
        assertEq(payment2.id, tokenPaymentId);

        // Test payer releasing the payment
        uint256 receiverEthBefore = address(receiver).balance;
        uint256 receiverTokensBefore = testToken.balanceOf(receiver);
        uint256 vaultEthBefore = address(settings.vaultAddress()).balance;
        uint256 vaultTokensBefore = testToken.balanceOf(settings.vaultAddress());

        // Payer releases ETH payment
        vm.startPrank(payerETH);
        vm.expectEmit(true, false, false, true);
        emit ReleaseAssentGiven(ethPaymentId, payerETH, 2); // 2 = payer assent type
        escrow.releaseEscrow(ethPaymentId);
        vm.stopPrank();

        // Payer releases token payment  
        vm.startPrank(payerToken);
        vm.expectEmit(true, false, false, true);
        emit ReleaseAssentGiven(tokenPaymentId, payerToken, 2);
        escrow.releaseEscrow(tokenPaymentId);
        vm.stopPrank();
        // Verify payments are not yet released since we need receiver consent
        assertEq(address(escrow).balance, 1 ether, "Escrow should still have ETH");
        assertEq(testToken.balanceOf(address(escrow)), 1000 * 10**18, "Escrow should still have tokens");

        // Receiver releases ETH payment
        vm.startPrank(receiver);
        vm.expectEmit(true, false, false, true);
        emit ReleaseAssentGiven(ethPaymentId, receiver, 1); // 1 = receiver assent type
        vm.expectEmit(true, false, false, true);
        emit EscrowReleased(ethPaymentId, 0.975 ether, 0.025 ether); // 2.5% fee
        escrow.releaseEscrow(ethPaymentId);
        vm.stopPrank();

        // Receiver releases token payment
        vm.startPrank(receiver);
        vm.expectEmit(true, false, false, true);
        emit ReleaseAssentGiven(tokenPaymentId, receiver, 1);
        vm.expectEmit(true, false, false, true);
        emit EscrowReleased(tokenPaymentId, 975 * 10**18, 25 * 10**18); // 2.5% fee
        escrow.releaseEscrow(tokenPaymentId);
        vm.stopPrank();

        // Verify receiver balances after release
        assertEq(address(receiver).balance - receiverEthBefore, 0.975 ether, "Receiver should have received 97.5% of ETH");
        assertEq(testToken.balanceOf(receiver) - receiverTokensBefore, 975 * 10**18, "Receiver should have received 97.5% of tokens");

        // Verify vault received fees
        assertEq(address(settings.vaultAddress()).balance - vaultEthBefore, 0.025 ether, "Vault should have received 2.5% ETH fee");
        assertEq(testToken.balanceOf(settings.vaultAddress()) - vaultTokensBefore, 25 * 10**18, "Vault should have received 2.5% token fee");

        // Verify escrow is empty
        assertEq(address(escrow).balance, 0, "Escrow should have 0 ETH");
        assertEq(testToken.balanceOf(address(escrow)), 0, "Escrow should have 0 tokens");

    }

    function testRefundEscrow() public {
        // Store payment IDs
        bytes32 ethPaymentId1 = keccak256(abi.encodePacked("eth1"));
        bytes32 ethPaymentId2 = keccak256(abi.encodePacked("eth2")); 
        bytes32 tokenPaymentId1 = keccak256(abi.encodePacked("token1"));
        bytes32 tokenPaymentId2 = keccak256(abi.encodePacked("token2"));

        // Store initial balances
        uint256 payerEthBefore = payerETH.balance;
        uint256 payerTokensBefore = testToken.balanceOf(payerToken);

        // Create ETH payments
        PaymentInput[] memory ethPayments = new PaymentInput[](2);
        ethPayments[0] = PaymentInput({
            id: ethPaymentId1,
            receiver: receiver,
            payer: payerETH,
            amount: 1 ether
        });
        ethPayments[1] = PaymentInput({
            id: ethPaymentId2,
            receiver: receiver,
            payer: payerETH,
            amount: 1 ether
        });

        MultiPaymentInput[] memory ethMultiPayment = new MultiPaymentInput[](1);
        ethMultiPayment[0] = MultiPaymentInput({
            currency: address(0),
            payments: ethPayments
        });

        // Create token payments
        PaymentInput[] memory tokenPayments = new PaymentInput[](2);
        tokenPayments[0] = PaymentInput({
            id: tokenPaymentId1,
            receiver: receiver,
            payer: payerToken,
            amount: 1000 * 10**18
        });
        tokenPayments[1] = PaymentInput({
            id: tokenPaymentId2,
            receiver: receiver,
            payer: payerToken,
            amount: 1000 * 10**18
        });

        MultiPaymentInput[] memory tokenMultiPayment = new MultiPaymentInput[](1);
        tokenMultiPayment[0] = MultiPaymentInput({
            currency: address(testToken),
            payments: tokenPayments
        });

        // Place ETH payments
        vm.prank(payerETH);
        escrow.placeMultiPayments{value: 2 ether}(ethMultiPayment);

        // Place token payments
        vm.startPrank(payerToken);
        testToken.approve(address(escrow), 2000 * 10**18);
        escrow.placeMultiPayments(tokenMultiPayment);
        vm.stopPrank();

        // Verify escrow received payments
        assertEq(address(escrow).balance, 2 ether, "Escrow should have ETH");
        assertEq(testToken.balanceOf(address(escrow)), 2000 * 10**18, "Escrow should have tokens");

        // Test unauthorized refund attempts
        vm.startPrank(payerETH);
        vm.expectRevert("Unauthorized");
        escrow.refundPayment(ethPaymentId1, 1 ether);
        vm.stopPrank();

        vm.startPrank(unauthorized);
        vm.expectRevert("Unauthorized");
        escrow.refundPayment(ethPaymentId1, 1 ether);
        vm.stopPrank();

        vm.startPrank(admin);
        vm.expectRevert("Unauthorized");
        escrow.refundPayment(ethPaymentId1, 1 ether);
        vm.stopPrank();

        // Receiver refunds first payments
        vm.startPrank(receiver);
        escrow.refundPayment(ethPaymentId1, 1 ether);
        escrow.refundPayment(tokenPaymentId1, 1000 * 10**18);
        vm.stopPrank();

        // Verify first payments refunded
        assertEq(payerETH.balance, payerEthBefore - 1 ether, "Half of ETH should be refunded to payer");
        assertEq(testToken.balanceOf(payerToken), payerTokensBefore - 1000 * 10**18, "Half of tokens should be refunded");

        // Arbiter refunds second payments
        vm.startPrank(arbiter);
        escrow.refundPayment(ethPaymentId2, 1 ether);
        escrow.refundPayment(tokenPaymentId2, 1000 * 10**18);
        vm.stopPrank();

        // Verify all payments refunded
        assertEq(address(escrow).balance, 0, "Escrow should have 0 ETH");
        assertEq(testToken.balanceOf(address(escrow)), 0, "Escrow should have 0 tokens");
        assertEq(payerETH.balance, payerEthBefore, "All ETH should be refunded");
        assertEq(testToken.balanceOf(payerToken), payerTokensBefore, "All tokens should be refunded");
    }


}

