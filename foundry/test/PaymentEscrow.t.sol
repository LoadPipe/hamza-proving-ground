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

    function testTransferArbiterHat() public {
        // Get initial arbiter hat ID from security context
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

    function testPlaceMultiPayments() public {
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

    }

    // function testReleaseEscrow() public {
    //     // Place both ETH and token payments first (similar to testPlaceMultiPayments)
    //     bytes32 ethPaymentId = keccak256(abi.encodePacked("0x01"));
    //     bytes32 tokenPaymentId = keccak256(abi.encodePacked("0x02"));
        
    //     // Place ETH payment
    //     PaymentInput[] memory ethPayments = new PaymentInput[](1);
    //     ethPayments[0] = PaymentInput({
    //         id: ethPaymentId,
    //         receiver: receiver,
    //         payer: payerETH,
    //         amount: 1 ether
    //     });
    //     MultiPaymentInput[] memory ethMultiPayment = new MultiPaymentInput[](1);
    //     ethMultiPayment[0] = MultiPaymentInput({
    //         currency: address(0),
    //         payments: ethPayments
    //     });
        
    //     vm.prank(payerETH);
    //     escrow.placeMultiPayments{value: 1 ether}(ethMultiPayment);

    //     // Place token payment
    //     PaymentInput[] memory tokenPayments = new PaymentInput[](1);
    //     tokenPayments[0] = PaymentInput({
    //         id: tokenPaymentId,
    //         receiver: receiver,
    //         payer: payerToken,
    //         amount: 1000 * 10**18
    //     });
    //     MultiPaymentInput[] memory tokenMultiPayment = new MultiPaymentInput[](1);
    //     tokenMultiPayment[0] = MultiPaymentInput({
    //         currency: address(testToken),
    //         payments: tokenPayments
    //     });

    //     vm.startPrank(payerToken);
    //     testToken.approve(address(escrow), 1000 * 10**18);
    //     escrow.placeMultiPayments(tokenMultiPayment);
    //     vm.stopPrank();

    //     // Test releasing the payments
    //     uint256 receiverEthBefore = address(receiver).balance;
    //     uint256 receiverTokensBefore = testToken.balanceOf(receiver);

    //     // Release ETH payment
    //     vm.startPrank(arbiter);
    //     vm.expectEmit(true, false, false, true);
    //     emit EscrowReleased(ethPaymentId, 0.975 ether, 0.025 ether); // 2.5% fee
    //     escrow.releaseEscrow(ethPaymentId);

    //     // Release token payment
    //     vm.expectEmit(true, false, false, true);
    //     emit EscrowReleased(tokenPaymentId, 975 * 10**18, 25 * 10**18); // 2.5% fee
    //     escrow.releaseEscrow(tokenPaymentId);
    //     vm.stopPrank();

    //     // Verify balances after release
    //     assertEq(address(receiver).balance - receiverEthBefore, 1 ether, "Receiver should have received 1 ETH");
    //     assertEq(testToken.balanceOf(receiver) - receiverTokensBefore, 1000 * 10**18, "Receiver should have received 1000 tokens");
    //     assertEq(address(escrow).balance, 0, "Escrow should have 0 ETH");
    //     assertEq(testToken.balanceOf(address(escrow)), 0, "Escrow should have 0 tokens");
    // }


}

